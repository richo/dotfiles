import * as wasm from "logic";

window.onload = function() {
  // Wire up the rando-episode buttan
  let button = document.getElementById("rando-episode");
  button.addEventListener("click", function() {
    wasm.play_weighted_random_episode();
  });

  let base = wasm.url_base();

  // Populate the episode list
  for (let {name, link} of wasm.episode_list()) {
    let li = document.createElement("li");
    let a = document.createElement("a");
    let content = document.createTextNode(name);

    a.href = base + link;
    a.appendChild(content);

    li.appendChild(a);

    document.getElementById("episode-list").appendChild(li);
  }
}
