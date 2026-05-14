// Import the functions you need from the SDKs you need
import { initializeApp } from "https://www.gstatic.com/firebasejs/12.11.0/firebase-app.js";
import { getAuth, onAuthStateChanged, GoogleAuthProvider, signInWithPopup } from "https://www.gstatic.com/firebasejs/12.11.0/firebase-auth.js";
import { doc, getFirestore, collection, addDoc, serverTimestamp, getDocs, updateDoc, increment } from "https://www.gstatic.com/firebasejs/12.11.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyBEYwlIp5ghxtxOmIY6szJ2bWbft7DlIjQ",
  authDomain: "cihcahulplus.firebaseapp.com",
  projectId: "cihcahulplus",
  storageBucket: "cihcahulplus.firebasestorage.app",
  messagingSenderId: "573175759927",
  appId: "1:573175759927:web:2ae6a2f102bf3ad2f7abb2",
  measurementId: "G-GNRKJ1ZLD5"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore();
const provider = new GoogleAuthProvider();

export const getGoogleSub = async () => {
  const user = auth.currentUser
  const googleProfile = user.providerData.find(
    (profile) => profile.providerId === "google.com"
  );
  return googleProfile ? googleProfile.uid : null;
}

export const saveFeedback = async (stars, text_content, choices) => {
  try {
    const user = auth.currentUser

    const googleSub = await getGoogleSub();

    const docRef = await addDoc(collection(db, "feedbacks"), {
      stars: stars, 
      text: text_content ?? "",
      choice1: choices[0].id ?? "",
      choice2: choices[1].id ?? "",
      agree: 0,
      disagree: 0,
      userName: user.displayName,
      photoURL: user.photoURL,
      googleSub: googleSub,
      email: user.email,
      createdAt: serverTimestamp()
    })

    return { success: true, id: docRef.id };
  } catch (e) {
    console.error(e)
    return { success: false, error: e.message };
  }
}

export const isCorrectDomain = () => {
  const user = auth.currentUser;
  if (user) {
    const domain = user.email.split("@")[1];
    return domain.includes("elev.cihcahul.md");
  }
  return false
}

export const initFirebase = () => {
  onAuthStateChanged(auth, (user) => {
    if (user) {
      
      const params = new URLSearchParams(window.location.search);
      const publish = $(".publish");
      const star = params.get("star");

      $(".known_user").style.display = "flex";
      $(".known_user .user_info .user_name").textContent = user.displayName;
      $(".known_user .user_info img").style.display = "flex";
      $(".known_user .user_info img").src = user.photoURL;

      const domain = user.email.split("@")[1];
      if (domain.includes("elev.cihcahul.md")) {
        $(".invalid_email_warning").style.display = "none";
        if (publish && star > 0) publish.style.color = "var(--text-color-variation)";
      } else {
        $(".invalid_email_warning").style.display = "flex";
        if (publish) publish.style.color = "var(--secondary-text-color)";
      }
    } else {
      $(".unknown_user").style.display = "flex";
    }
  });

  async function loginWithGoogle() {
    try {
      const result = await signInWithPopup(auth, provider);
      const user = result.user;
      $(".known_user").style.display = "flex";
      $(".unknown_user").style.display = "none";
      $(".known_user .user_info .user_name").textContent = user.displayName;
      $("header .publish").style.color = "var(--text-color-variation)"
    } catch (e) {
      console.error(e);
    }
  }

  if ($(".reg_with_google")) 
    $(".reg_with_google").on("click", () => { loginWithGoogle(); })

  if ($(".known_user .user_info")) 
    $(".known_user .user_info").on("click", () => { loginWithGoogle(); })
} 

export const getFeedbacks = async () => {
  const querySnapshot = await getDocs(collection(db, "feedbacks"));
  const data = querySnapshot.docs.map(doc => {
    const d = doc.data()
    return {
      id: d.id,
      agree: d.agree,
      createdAt: d.createdAt,
      googleSub: d.googleSub,
      photoURL: d.photoURL,
      stars: d.stars,
      text: d.text,
      userName: d.userName
    }
  });
  return data
} 

export const changeAgreeParam = async (id) => {
  if (!id) return;

  const ref = doc(db, "feedbacks", id);
  await updateDoc(ref, { agree: increment(1) });
}

export const changeDisagreeParam = async (id) => {
  if (!id) return;

  const ref = doc(db, "feedbacks", id);
  await updateDoc(ref, { disagree: increment(1) });
}