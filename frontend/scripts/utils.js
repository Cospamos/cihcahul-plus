const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);

Element.prototype.on = function (event, handler, options) {
  this.addEventListener(event, handler, options);
}

NodeList.prototype.on = function (event, handler, options) {
  let handlers = [];
  this.forEach(el => {
    el.addEventListener(event, handler, options);
  })
  return handlers
}