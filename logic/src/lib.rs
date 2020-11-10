use wasm_bindgen::prelude::*;
use std::collections::HashMap;
use rand::{
    thread_rng,
    seq::SliceRandom,
};
use web_sys;
use serde::{Serialize, Deserialize};
use serde_json;

const URL_BASE: &'static str = "https://archive.org";


#[derive(Serialize, Deserialize, Hash, Eq, PartialEq, Copy, Clone, Debug)]
struct Episode {
    name: &'static str,
    link: &'static str,
}

impl Episode {
    fn url(&self) -> String {
        format!("{}{}", URL_BASE, self.link)
    }
}

enum Player {
    Redirect,
    Embedded,
}

static DB: &[Episode] = &[
    Episode {name: "1. 01 Thunderbirds - Trapped in the sky", link: "/download/GerryAnderson2/01Thunderbirds-TrappedInTheSky.mp4"},
    Episode {name: "2. 02 Thunderbirds - Pit Of Peril", link: "/download/GerryAnderson2/02Thunderbirds-PitOfPeril.mp4"},
    Episode {name: "3. 03 Thunderbirds - The Perils Of Penelope", link: "/download/GerryAnderson2/03Thunderbirds-ThePerilsOfPenelope.mp4"},
    Episode {name: "4. 04 Thunderbirds - Terror In New York City", link: "/download/GerryAnderson2/04Thunderbirds-TerrorInNewYorkCity.mp4"},
    Episode {name: "5. 05 Thunderbirds - Edge Of Impact", link: "/download/GerryAnderson2/05Thunderbirds-EdgeOfImpact.mp4"},
    Episode {name: "6. 06 Thunderbirds - Day Of Disaster", link: "/download/GerryAnderson2/06Thunderbirds-DayOfDisaster.mp4"},
    Episode {name: "7. 07 Thunderbirds - 30 Minutes After Noon", link: "/download/GerryAnderson2/07Thunderbirds-30MinutesAfterNoon.mp4"},
    Episode {name: "8. 08 Thunderbirds - Desperate Intruder", link: "/download/GerryAnderson2/08Thunderbirds-DesperateIntruder.mp4"},
    Episode {name: "9. 09 Thunderbirds - Operation Crash-Dive", link: "/download/GerryAnderson2/09Thunderbirds-OperationCrash-dive.mp4"},
    Episode {name: "10. 10 Thunderbirds - Sun Probe", link: "/download/GerryAnderson2/10Thunderbirds-SunProbe.mp4"},
    Episode {name: "11. 11 Thunderbirds - The Uninvited", link: "/download/GerryAnderson2/11Thunderbirds-TheUninvited.mp4"},
    Episode {name: "12. 12 Thunderbirds - End Of The Road", link: "/download/GerryAnderson2/12Thunderbirds-EndOfTheRoad.mp4"},
    Episode {name: "13. 13 Thunderbirds - The Imposters", link: "/download/GerryAnderson2/13Thunderbirds-TheImposters.mp4"},
    Episode {name: "14. 14 Thunderbirds - City Of Fire", link: "/download/GerryAnderson2/14Thunderbirds-CityOfFire.mp4"},
    Episode {name: "15. 15 Thunderbirds - The Mighty Atom", link: "/download/GerryAnderson2/15Thunderbirds-TheMightyAtom.mp4"},
    Episode {name: "16. 16 Thunderbirds - Vault Of Death", link: "/download/GerryAnderson2/16Thunderbirds-VaultOfDeath.mp4"},
    Episode {name: "17. 17 Thunderbirds - The Man From MI.5", link: "/download/GerryAnderson2/17Thunderbirds-TheManFromMi.5.mp4"},
    Episode {name: "18. 18 Thunderbirds - Cry Wolf", link: "/download/GerryAnderson2/18Thunderbirds-CryWolf.mp4"},
    Episode {name: "19. 19 Thunderbirds - Danger At Ocean Deep", link: "/download/GerryAnderson2/19Thunderbirds-DangerAtOceanDeep.mp4"},
    Episode {name: "20. 20 Thunderbirds - Move_And You're Dead", link: "/download/GerryAnderson2/20Thunderbirds-Move_andYoureDead.mp4"},
    Episode {name: "21. 21 Thunderbirds - The Dutchess Assignment", link: "/download/GerryAnderson2/21Thunderbirds-TheDutchessAssignment.mp4"},
    Episode {name: "22. 22 Thunderbirds - Brink Of Disaster", link: "/download/GerryAnderson2/22Thunderbirds-BrinkOfDisaster.mp4"},
    Episode {name: "23. 23 Thunderbirds - Attack Of The Alligators", link: "/download/GerryAnderson2/23Thunderbirds-AttackOfTheAlligators.mp4"},
    Episode {name: "24. 24 Thunderbirds - Martian Invasion", link: "/download/GerryAnderson2/24Thunderbirds-MartianInvasion.mp4"},
    Episode {name: "25. 25 Thunderbirds - The Cham-Cham", link: "/download/GerryAnderson2/25Thunderbirds-TheCham-cham.mp4"},
    Episode {name: "26. 26 Thunderbirds - Security Hazard", link: "/download/GerryAnderson2/26Thunderbirds-SecurityHazard.mp4"},
    Episode {name: "27. 27 Thunderbirds - Atlantic Inferno", link: "/download/GerryAnderson2/27Thunderbirds-AtlanticInferno.mp4"},
    Episode {name: "28. 28 Thunderbirds - Path Of Destruction", link: "/download/GerryAnderson2/28Thunderbirds-PathOfDestruction.mp4"},
    Episode {name: "29. 29 Thunderbirds - Alias Mr. Hackenbacker", link: "/download/GerryAnderson2/29Thunderbirds-AliasMr.Hackenbacker.mp4"},
    Episode {name: "30. 30 Thunderbirds - Lord Parker's 'Oliday", link: "/download/GerryAnderson2/30Thunderbirds-LordParkersoliday.mp4"},
    Episode {name: "31. 31 Thunderbirds - Ricochet", link: "/download/GerryAnderson2/31Thunderbirds-Ricochet.mp4"},
    Episode {name: "32. 32 Thunderbirds - Give Or Take A Million", link: "/download/GerryAnderson2/32Thunderbirds-GiveOrTakeAMillion.mp4"}
];

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern {
    fn playVideo(url: &str);
}

pub fn get_storage() -> Option<web_sys::Storage> {
    let window = web_sys::window().unwrap();

    match window.local_storage() {
        Ok(Some(local_storage)) => {
            Some(local_storage)
        },
        Err(_) => None,
        Ok(None) => None
    }
}

fn load() -> HashMap<String, usize> {
    if let Some(storage) = get_storage() {
        if let Ok(Some(text)) = storage.get_item("state") {
            // who cares any more
            let leaked: &'static str = Box::leak(text.into_boxed_str());
            if let Ok(data) = serde_json::from_str(&leaked) {
                return data
            }
        }
    }
    // Any invalid state we'll just start over who cares
    return HashMap::new();
}

fn save(state: HashMap<String, usize>) {
    if let Some(storage) = get_storage() {
        match serde_json::to_string(&state) {
            Ok(data) => {
                let _ = storage.set_item("state", &data);
            },
            _ => {},
        }
    }
}

#[wasm_bindgen]
pub fn play_weighted_random_episode() {
    let player_type = Player::Embedded;
    let mut state = load();
    let max = DB.iter()
        .map(|ep| state.get(ep.name).unwrap_or(&0))
        .max()
        .unwrap_or(&0) + &1;

    let mut rng = thread_rng();
    let ep = DB.choose_weighted(&mut rng, |ep| max - state.get(ep.name).unwrap_or(&0))
        .unwrap();

    let url = ep.url();

    let counter = state.entry(ep.name.into()).or_insert(0);
    *counter += 1;

    save(state);
    match player_type {
        Player::Embedded => play_embedded(&url),
        Player::Redirect => play_redirect(&url),
    }
}

fn play_redirect(url: &str) {
    let window = web_sys::window().unwrap();
    let location = window.location();
    let _ = location.assign(url);
}

fn play_embedded(url: &str) {
    playVideo(url);
}

#[wasm_bindgen]
pub fn episode_list() -> JsValue {
    JsValue::from_serde(DB).unwrap()
}

#[wasm_bindgen]
pub fn url_base() -> JsValue {
    JsValue::from_serde(URL_BASE).unwrap()
}
