const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

// ເລີ່ມຕົ້ນ Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

/**
 * 1. BCEL OnePay / LAPNet Webhook Endpoint
 * Method: POST /bcelWebhook
 * 
 * Endpoint ນີ້ຮອງຮັບການຍິງ Callback ຈາກທະນາຄານ ເມື່ອລູກຄ້າສະແກນ QR ຈ່າຍເງິນສຳເລັດ
 */
app.post("/bcelWebhook", async (req, res) => {
  try {
    const payload = req.body || {};
    console.log("=== ໄດ້ຮັບ Webhook ຈາກທະນາຄານ ===", JSON.stringify(payload));

    // ດຶງຂໍ້ມູນມາດຕະຖານຈາກທະນາຄານ (ຮອງຮັບທັງ BCEL OnePay ແລະ LAPNet)
    const orderRef = payload.orderRef || payload.order_id || payload.ref;
    const billNo = payload.billNo || payload.transactionId || payload.trans_id || `BCEL-${Date.now()}`;
    const amount = Number(payload.amount || payload.total || 0);
    const status = (payload.status || "SUCCESS").toUpperCase();

    if (!orderRef) {
      return res.status(400).json({
        code: "40",
        message: "Missing orderRef parameter",
      });
    }

    // ກວດສອບສະຖານະການຈ່າຍເງິນຈາກທະນາຄານ
    const isSuccess = status === "SUCCESS" || status === "PAID" || status === "00";
    if (!isSuccess) {
      console.warn(`[Webhook Warning] ການຊຳລະເງິນບໍ່ສຳເລັດ: Order=${orderRef}, Status=${status}`);
      return res.status(400).json({
        code: "01",
        message: "Payment was not successful",
      });
    }

    // ກວດສອບ ແລະ ອັບເດດຕົ໋ວໃນ Cloud Firestore
    const ticketRef = db.collection("tickets").doc(orderRef);
    const docSnapshot = await ticketRef.get();

    const updateData = {
      status: "paid",
      paymentMethod: payload.paymentMethod || "BCEL OnePay (Webhook)",
      transactionId: billNo,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (amount > 0) {
      updateData.totalAmount = amount;
    }

    if (docSnapshot.exists) {
      // ຖ້າມີຕົ໋ວຢູ່ແລ້ວ ໃຫ້ອັບເດດສະຖານະເປັນ paid
      await ticketRef.update(updateData);
      console.log(`[Webhook Success] ອັບເດດຕົ໋ວສຳເລັດ: ${orderRef} ➔ paid`);
    } else {
      // ຖ້າຫາກຍັງບໍ່ທັນມີ (ເຊັ່ນ: Order ສ້າງຈາກ Gateway ພາຍນອກ) ໃຫ້ສ້າງໃໝ່
      await ticketRef.set({
        id: orderRef,
        userId: payload.userId || "passenger_user",
        userEmail: payload.userEmail || "passenger@brt.la",
        originStation: payload.originStation || "station_talatxao",
        destinationStation: payload.destinationStation || "station_dongdok",
        quantity: payload.quantity || 1,
        totalAmount: amount || 7000,
        currency: "LAK",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
        ...updateData,
      });
      console.log(`[Webhook Success] ສ້າງຕົ໋ວໃໝ່ສຳເລັດ: ${orderRef} ➔ paid`);
    }

    // ສົ່ງ Status Code 200 ກັບໄປຫາທະນາຄານ (ມາດຕະຖານ BCEL OnePay)
    return res.status(200).json({
      code: "00",
      message: "Success",
      orderRef: orderRef,
      transactionId: billNo,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("[Webhook Error]:", error);
    return res.status(500).json({
      code: "99",
      message: "Internal server error processing webhook",
      error: error.message,
    });
  }
});

/**
 * 2. Simulation Endpoint ສຳລັບ Developer ທົດສອບ
 * Method: POST/GET /simulatePayment
 * 
 * ໃຊ້ສຳລັບທົດສອບຍິງ Webhook ທຽມໃນ Postman ຫຼື ຜ່ານ Browser ໂດຍບໍ່ຕ້ອງໂອນເງິນຈິງ
 */
app.all("/simulatePayment", async (req, res) => {
  const orderRef = req.body?.orderRef || req.query.orderRef;
  const billNo = req.body?.billNo || req.query.billNo || `SIM-BILL-${Date.now()}`;
  const amount = Number(req.body?.amount || req.query.amount || 7000);

  if (!orderRef) {
    return res.status(400).json({
      error: "ກະລຸນາສົ່ງ orderRef ມາພ້ອມ ເຊັ່ນ: ?orderRef=BRT-ORD-12345",
    });
  }

  try {
    const ticketRef = db.collection("tickets").doc(orderRef);
    await ticketRef.set(
      {
        status: "paid",
        transactionId: billNo,
        paymentMethod: "BCEL OnePay (Simulation)",
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return res.status(200).json({
      success: true,
      message: `ຈຳລອງການໂອນເງິນສຳເລັດແລ້ວ! ຕົ໋ວ ${orderRef} ປ່ຽນເປັນ 'paid' ຮຽບຮ້ອຍ`,
      orderRef,
      billNo,
      amount,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

/**
 * 3. ກວດສອບສະຖານະການຊຳລະເງິນ (Check Status)
 * Method: GET /checkPaymentStatus?orderRef=...
 */
app.get("/checkPaymentStatus", async (req, res) => {
  const orderRef = req.query.orderRef;
  if (!orderRef) {
    return res.status(400).json({ error: "Missing orderRef" });
  }

  try {
    const doc = await db.collection("tickets").doc(orderRef).get();
    if (!doc.exists) {
      return res.status(404).json({ exists: false, isPaid: false });
    }
    const data = doc.data();
    return res.status(200).json({
      exists: true,
      orderRef,
      status: data.status,
      isPaid: data.status === "paid",
      transactionId: data.transactionId || null,
      totalAmount: data.totalAmount || 0,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

// Export Cloud Functions
exports.api = functions.https.onRequest(app);
exports.bcelWebhook = functions.https.onRequest(app);

