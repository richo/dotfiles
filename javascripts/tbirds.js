const url_base = "https://archive.org";
const db =[{"name": "1. 01 Thunderbirds - Trapped in the sky", "link": "/download/GerryAnderson2/01Thunderbirds-TrappedInTheSky.mp4"}, {"name": "2. 02 Thunderbirds - Pit Of Peril", "link": "/download/GerryAnderson2/02Thunderbirds-PitOfPeril.mp4"}, {"name": "3. 03 Thunderbirds - The Perils Of Penelope", "link": "/download/GerryAnderson2/03Thunderbirds-ThePerilsOfPenelope.mp4"}, {"name": "4. 04 Thunderbirds - Terror In New York City", "link": "/download/GerryAnderson2/04Thunderbirds-TerrorInNewYorkCity.mp4"}, {"name": "5. 05 Thunderbirds - Edge Of Impact", "link": "/download/GerryAnderson2/05Thunderbirds-EdgeOfImpact.mp4"}, {"name": "6. 06 Thunderbirds - Day Of Disaster", "link": "/download/GerryAnderson2/06Thunderbirds-DayOfDisaster.mp4"}, {"name": "7. 07 Thunderbirds - 30 Minutes After Noon", "link": "/download/GerryAnderson2/07Thunderbirds-30MinutesAfterNoon.mp4"}, {"name": "8. 08 Thunderbirds - Desperate Intruder", "link": "/download/GerryAnderson2/08Thunderbirds-DesperateIntruder.mp4"}, {"name": "9. 09 Thunderbirds - Operation Crash-Dive", "link": "/download/GerryAnderson2/09Thunderbirds-OperationCrash-dive.mp4"}, {"name": "10. 10 Thunderbirds - Sun Probe", "link": "/download/GerryAnderson2/10Thunderbirds-SunProbe.mp4"}, {"name": "11. 11 Thunderbirds - The Uninvited", "link": "/download/GerryAnderson2/11Thunderbirds-TheUninvited.mp4"}, {"name": "12. 12 Thunderbirds - End Of The Road", "link": "/download/GerryAnderson2/12Thunderbirds-EndOfTheRoad.mp4"}, {"name": "13. 13 Thunderbirds - The Imposters", "link": "/download/GerryAnderson2/13Thunderbirds-TheImposters.mp4"}, {"name": "14. 14 Thunderbirds - City Of Fire", "link": "/download/GerryAnderson2/14Thunderbirds-CityOfFire.mp4"}, {"name": "15. 15 Thunderbirds - The Mighty Atom", "link": "/download/GerryAnderson2/15Thunderbirds-TheMightyAtom.mp4"}, {"name": "16. 16 Thunderbirds - Vault Of Death", "link": "/download/GerryAnderson2/16Thunderbirds-VaultOfDeath.mp4"}, {"name": "17. 17 Thunderbirds - The Man From MI.5", "link": "/download/GerryAnderson2/17Thunderbirds-TheManFromMi.5.mp4"}, {"name": "18. 18 Thunderbirds - Cry Wolf", "link": "/download/GerryAnderson2/18Thunderbirds-CryWolf.mp4"}, {"name": "19. 19 Thunderbirds - Danger At Ocean Deep", "link": "/download/GerryAnderson2/19Thunderbirds-DangerAtOceanDeep.mp4"}, {"name": "20. 20 Thunderbirds - Move_And You\'re Dead", "link": "/download/GerryAnderson2/20Thunderbirds-Move_andYoureDead.mp4"}, {"name": "21. 21 Thunderbirds - The Dutchess Assignment", "link": "/download/GerryAnderson2/21Thunderbirds-TheDutchessAssignment.mp4"}, {"name": "22. 22 Thunderbirds - Brink Of Disaster", "link": "/download/GerryAnderson2/22Thunderbirds-BrinkOfDisaster.mp4"}, {"name": "23. 23 Thunderbirds - Attack Of The Alligators", "link": "/download/GerryAnderson2/23Thunderbirds-AttackOfTheAlligators.mp4"}, {"name": "24. 24 Thunderbirds - Martian Invasion", "link": "/download/GerryAnderson2/24Thunderbirds-MartianInvasion.mp4"}, {"name": "25. 25 Thunderbirds - The Cham-Cham", "link": "/download/GerryAnderson2/25Thunderbirds-TheCham-cham.mp4"}, {"name": "26. 26 Thunderbirds - Security Hazard", "link": "/download/GerryAnderson2/26Thunderbirds-SecurityHazard.mp4"}, {"name": "27. 27 Thunderbirds - Atlantic Inferno", "link": "/download/GerryAnderson2/27Thunderbirds-AtlanticInferno.mp4"}, {"name": "28. 28 Thunderbirds - Path Of Destruction", "link": "/download/GerryAnderson2/28Thunderbirds-PathOfDestruction.mp4"}, {"name": "29. 29 Thunderbirds - Alias Mr. Hackenbacker", "link": "/download/GerryAnderson2/29Thunderbirds-AliasMr.Hackenbacker.mp4"}, {"name": "30. 30 Thunderbirds - Lord Parker\'s \'Oliday", "link": "/download/GerryAnderson2/30Thunderbirds-LordParkersoliday.mp4"}, {"name": "31. 31 Thunderbirds - Ricochet", "link": "/download/GerryAnderson2/31Thunderbirds-Ricochet.mp4"}, {"name": "32. 32 Thunderbirds - Give Or Take A Million", "link": "/download/GerryAnderson2/32Thunderbirds-GiveOrTakeAMillion.mp4"}];

function choice(ary) {
    return ary[Math.floor(ary.length * Math.random())];
}

function weightedChoice(state, ary) {
  // Mutates state in place so you need to save it yourself when you're done
  let max = Math.max.apply(undefined, db.map(({name, link}) => state[link] || 1));
  var weightedAry = [];
  for (let i of db) {
    let weight = state[i.link] || 0;
    for (let j = 0; j < max - weight; j++) {
      weightedAry.push(i);
    }
  }
  let ret = choice(weightedAry);
  if (state[ret.link] === undefined) {
    state[ret.link] = 1;
  }
  state[ret.link] += 1;
  save(state);
  return ret;
}

function load() {
  let state = window.localStorage.getItem('state');
  if (state !== null) {
    return JSON.parse(state);
  }
  return {};
}

function save(state) {
  window.localStorage.setItem('state', JSON.stringify(state));
}

window.onload = function() {
  // See if we already have some counts
  let state = load();
  // Wire up the rando-episode buttan
  let button = document.getElementById("rando-episode");
  button.addEventListener("click", function() {
    let obj = weightedChoice(db, state);
    console.log(`playing ${obj.name}`);
    window.location = url_base + obj.link;
  });

  // Populate the episode list
  for (let { name, link} of db) {
    let li = document.createElement("li");
    let a = document.createElement("a");
    let content = document.createTextNode(name);

    a.href = url_base + link;
    a.appendChild(content);

    li.appendChild(a);

    document.getElementById("episode-list").appendChild(li);
  }
}
