import { initFirebase } from "./firebase.js";
import { initListeners } from "./listener.js";

(async () => {
  const pageInit = async (page) => {
    document.querySelector("head").innerHTML +=
      `<link rel="stylesheet" href="templates/${page}.css">`;
    const res = await fetch(`templates/${page}.html`);
    const data = await res.text();
    document.querySelector("content").innerHTML = data;
    document.querySelector("content").style.opacity = 1;
  }

  if (location.pathname == '/') {
    await pageInit("main_page")
  } else if (location.pathname.includes("/feedback")) {
    await pageInit("feedback_page");
  } else if (location.pathname == "/rules") {
    await pageInit("rules_page");
  } else if (location.pathname == "/description") {
    await pageInit("description_page");
  } else {
    await pageInit("main_page");
  }

  initFirebase()
  initListeners()
})()