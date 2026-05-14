import { 
  isCorrectDomain, 
  saveFeedback, 
  getFeedbacks, 
  changeAgreeParam, 
  changeDisagreeParam, 
  getGoogleSub,
} from "./firebase.js";

const _createFeedbackCards = async () => {
  const choices_container = document.querySelector(".feedback_cards");
  if (!choices_container) return;

  const data = await getFeedbacks()
  data.forEach(async (item) => {
    if (!item.text) return;

    const feedback_card = document.createElement("div");
    choices_container.append(feedback_card)
    feedback_card.className = "feedback_card";
    feedback_card.innerHTML += `
    <div class="user">
      <div class="icon">
        <i class="fa-solid fa-user"></i>
        <img src="">
      </div>
      <h3 class="name"></h3>
    </div>
    <div class="rating_info">
      <div class="rating_sars">
        <img src="assets/star.svg">
        <img src="assets/star.svg">
        <img src="assets/star.svg">
        <img src="assets/star.svg">
        <img src="assets/star.svg">
      </div>
      <p class="date"></p>
    </div>
    <div class="review_text"></div>
    <div class="review_helpful"></div>`

    const d = item.createdAt.toDate()
    const formatted =
      String(d.getDate()).padStart(2, '0') + '.' +
      String(d.getMonth() + 1).padStart(2, '0') + '.' +
      d.getFullYear();

    feedback_card.querySelector(".icon img").src = item.photoURL;
    feedback_card.querySelector(".name").textContent = item.userName;
    feedback_card.querySelector(".review_text").textContent = item.text;
    feedback_card.querySelector(".date").textContent = formatted;
    feedback_card.querySelector(".review_text").textContent = item.text;

    for (let i = 0; i < item.stars; i++) {
      feedback_card.querySelectorAll(".rating_sars img")[i].src = "../assets/star_fill.svg"
    }

    if (item.agree > 1) {
      feedback_card.querySelector(".review_helpful").textContent = 
        `${item.agree} человека считают этот отзыв полезным`
    } else if (item.agree > 0) {
      feedback_card.querySelector(".review_helpful").textContent = 
        `${item.agree} человек считает этот отзыв полезным`
    }

    const googleSub = await getGoogleSub();
    if (item.googleSub != googleSub) {
      feedback_card.innerHTML += `
      <div class="review_pull">
        <p>Был ли этот отзыв полезен?</p>
        <button class="yes">Да</button>
        <button class="no">Нет</button>
      </div>`

      feedback_card.querySelector("button.yes").on("click", () => {
        changeAgreeParam(item.id);
      })

      feedback_card.querySelector("button.no").on("click", () => {
        changeDisagreeParam(item.id);
      })
    } 
  })
}

const _setreViewDistribution = async () => {
  const graphContainer = document.querySelector(".graph_container")
  if (!graphContainer) return;

  const data = await getFeedbacks()
  let sumStars = 0;
  let sumByType = [0, 0, 0, 0, 0];

  data.forEach(item => {
    sumStars += Number(item.stars);
    sumByType[Number(item.stars) - 1] += 1;
  })

  const mediaStars = sumStars / data.length;
  
  graphContainer.querySelector(".ratting_summary h1").textContent = mediaStars.toFixed(1);
  graphContainer.querySelector(".feedbacks_cnt").textContent = data.length;
  
  const stars = graphContainer.querySelectorAll(".rating_sars img")
  for (let i = 0; i < Math.floor(mediaStars); i++) {
    stars[i].src = "../assets/star_fill.svg";
  }

  const progress = [...graphContainer.querySelectorAll(".review_distribution .progress")].reverse();
  for (let i = 0; i < sumByType.length; i++) {
    progress[i].style.width = `${(sumByType[i] / data.length) * 100}%`
  }
} 

export const initListeners = () =>  {
  const stars = $$(".feedback_react_stars img");
  const params = new URLSearchParams(window.location.search);
  const publish = $(".publish");
  const is_correct_domain = isCorrectDomain()

  let star_idx = params.get("star");
  let feedback_text_content = ""
  
  let last_choices = {};
  
  _createFeedbackCards();
  _setreViewDistribution();
  if (!star_idx && publish && !is_correct_domain) publish.style.color = "var(--secondary-text-color)"

  for (let i = 0; i < star_idx; i++)
    stars[i].src = "../assets/star_fill.svg";
  
  stars.forEach((el, idx) => {
    el.on("click", () => {
      const is_correct_domain = isCorrectDomain()
      for (let i = 0; i < stars.length; i++) {
        stars[i].src = (i <= idx) ? 
          "../assets/star_fill.svg" : "../assets/star.svg"

        if (!location.pathname.includes("/feedback")) {
          window.location.href = `/feedback?star=${idx+1}`;
        }
      }
      star_idx = idx;
      if (publish && is_correct_domain) publish.style.color = "var(--text-color-variation)"
    })
  })

  publish.on("click", async () => { 
    const is_correct_domain = isCorrectDomain()
    if (Number(star_idx)+1 > 0 && is_correct_domain) {
      const res = await saveFeedback(Number(star_idx)+1, feedback_text_content, last_choices)
      if (res.success) {
        window.location.href = "/";
      }
    }
  })

  const textArea = $(".feedback_text_content_container textarea");
  const counter = $(".feedback_text_content_container p")

  textArea.on('input', () => {
    counter.textContent = `${textArea.value.length}/500`
    feedback_text_content = textArea.value;
  })

  const choices = $$(".choice");
  const dots = $$(".dot");

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const index = [...choices].indexOf(entry.target);
        dots.forEach(d => d.classList.remove("active"));
        dots[index].classList.add("active");
      }
    });
  }, { threshold: 0.6 });
  choices.forEach(el => observer.observe(el));
  
  
  choices.forEach((choice, idx) => {
    const action_buttons = choice.querySelectorAll(".actions button");
    const button_id = ["true", "unknown", "false"]
    last_choices[idx] = last_choices[idx] || {}
    action_buttons.forEach((el, i) => {
      el.on("click", () => {
        if (last_choices[idx].el) last_choices[idx].el.classList.remove("active")
        el.classList.add("active")
        last_choices[idx] = {el: el, id: button_id[i]}
      })
    })
  })
}