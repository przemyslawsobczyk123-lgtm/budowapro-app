"use strict";

const screenMeta = {
  overview: {
    title: "Centrum budowy",
    panelTitle: "Centrum decyzyjne inwestora",
    panelText:
      "Pierwszy ekran pokazuje budzet, ryzyka etapu i najblizsze wizyty. Uzytkownik widzi co ma zrobic dzisiaj, bez szukania w Excelu.",
  },
  costs: {
    title: "Koszty budowy",
    panelTitle: "Rejestr kosztow zamiast Excela",
    panelText:
      "Kazdy wydatek ma etap, kategorie, dostawce, status, dokument i tagi. Filtry i sumy sa natychmiastowe.",
  },
  "add-cost": {
    title: "Dodaj koszt",
    panelTitle: "Szybkie wpisywanie pozycji",
    panelText:
      "Manualny koszt musi byc szybszy niz Excel. Formularz zbiera tylko dane potrzebne do filtrowania, raportow i gwarancji.",
  },
  scan: {
    title: "Skan OCR",
    panelTitle: "Paragon z kontrola uzytkownika",
    panelText:
      "OCR proponuje pozycje, ale nie zmienia budzetu bez potwierdzenia. Niska pewnosc wymaga korekty.",
  },
  stages: {
    title: "Etapy budowy",
    panelTitle: "Checklisty chronia przed bledami",
    panelText:
      "Stan 0 pilnuje przepustow, bednarki, izolacji i zdjec przed ukryciem prac. Kazdy punkt moze miec dowod.",
  },
  contacts: {
    title: "Ekipy i terminy",
    panelTitle: "Kontakty powiazane z etapami",
    panelText:
      "Kontakt to nie tylko telefon. Ma role, oferty, wizyty, etapy, notatki i dokumenty.",
  },
  documents: {
    title: "Dokumenty",
    panelTitle: "Dowody, faktury, gwarancje",
    panelText:
      "Dokumenty sa lokalne i powiazane z kosztami lub checklistami. To ulatwia odbiory, reklamacje i eksport.",
  },
  technical: {
    title: "Techniczne",
    panelTitle: "Zdjecia etapow i instalacji",
    panelText:
      "Kazdy etap ma album techniczny: zdjecia przed zakryciem, mapy przewodow, protokoly i tagi pomieszczen. Wszystko lokalnie na telefonie.",
  },
  rooms: {
    title: "Pomieszczenia",
    panelTitle: "Tryb remontu i wykonczenia",
    panelText:
      "Pomieszczenia lacza budzet, decyzje zakupowe, zdjecia i pomiary. To przydatne przy remontach, wykonczeniu i zmianach lokatorskich.",
  },
  materials: {
    title: "Zakupy",
    panelTitle: "Materialy, dostawy i zwroty",
    panelText:
      "Zakupy maja statusy: plan, zamowione, dostarczone, czesciowo odebrane, zwrot. Uzytkownik widzi opoznienia i nadmiary.",
  },
  punchlist: {
    title: "Odbiory",
    panelTitle: "Usterki i protokoly odbioru",
    panelText:
      "Punch list zapisuje zdjecie, lokalizacje, osobe odpowiedzialna, termin i status. Przy odbiorach nie ginie zadna poprawka.",
  },
  reports: {
    title: "Raporty",
    panelTitle: "Podsumowania bez arkusza",
    panelText:
      "Raporty odpowiadaja na pytania: ile wydano, na co, komu, kiedy i co zostalo do zaplaty.",
  },
  settings: {
    title: "Ustawienia",
    panelTitle: "Prywatnosc jako funkcja produktu",
    panelText:
      "MVP jest local-first: brak konta, backendu i automatycznego uploadu dokumentow.",
  },
  more: {
    title: "Wiecej",
    panelTitle: "Jedno wejscie do dodatkowych narzedzi",
    panelText:
      "Glowna nawigacja ma tylko piec zakladek. Szybki zapis i kontekstowe skroty prowadza do szczegolowych modulow bez przeciazania telefonu.",
  },
  diary: {
    title: "Dziennik i decyzje",
    panelTitle: "Historia pracy i zmian zakresu",
    panelText:
      "Dziennik zapisuje postep, ekipy, zdjecia i opoznienia. Kazda decyzja zachowuje powod oraz wplyw na koszt i termin.",
  },
  assistant: {
    title: "Asystent BudowaPRO",
    panelTitle: "Najpierw reguly offline, AI tylko opcjonalnie",
    panelText:
      "Asystent wskazuje brakujace dowody, konflikty terminow i decyzje blokujace. Tworzy sugestie, ale nie odbiera prac ani nie zmienia budzetu.",
  },
  "home-record": {
    title: "Karta domu",
    panelTitle: "Dokumentacja pozostaje uzyteczna po budowie",
    panelText:
      "Po odbiorze projekt staje sie karta domu z urzadzeniami, gwarancjami, serwisem, mapa instalacji i historia remontow.",
  },
};

const primaryTabByScreen = {
  overview: "overview",
  stages: "stages",
  diary: "stages",
  costs: "costs",
  "add-cost": "costs",
  scan: "costs",
  materials: "costs",
  reports: "costs",
  technical: "technical",
  documents: "technical",
  punchlist: "technical",
  "home-record": "technical",
  more: "more",
  assistant: "more",
  rooms: "more",
  contacts: "more",
  settings: "more",
};

const navButtons = Array.from(document.querySelectorAll("[data-target]"));
const appTabButtons = Array.from(document.querySelectorAll("[data-app-target]"));
const screens = Array.from(document.querySelectorAll("[data-screen]"));
const title = document.querySelector("#screenTitle");
const panelTitle = document.querySelector("#panelTitle");
const panelText = document.querySelector("#panelText");

function setScreen(screenName) {
  const meta = screenMeta[screenName] ?? screenMeta.overview;
  const primaryTab = primaryTabByScreen[screenName] ?? "overview";

  navButtons.forEach((button) => {
    const isActive = button.dataset.target === screenName;
    button.classList.toggle("is-active", isActive);
    if (isActive) {
      button.setAttribute("aria-current", "page");
    } else {
      button.removeAttribute("aria-current");
    }
  });

  screens.forEach((screen) => {
    const isActive = screen.dataset.screen === screenName;
    screen.classList.toggle("is-active", isActive);
    screen.hidden = !isActive;
  });

  appTabButtons.forEach((button) => {
    const isActive = button.dataset.appTarget === primaryTab;
    button.classList.toggle("is-active", isActive);
    if (isActive) {
      button.setAttribute("aria-current", "page");
    } else {
      button.removeAttribute("aria-current");
    }
  });

  title.textContent = meta.title;
  panelTitle.textContent = meta.panelTitle;
  panelText.textContent = meta.panelText;
}

navButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setScreen(button.dataset.target);
  });
});

appTabButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setScreen(button.dataset.appTarget);
  });
});

document.querySelectorAll("[data-shortcut]").forEach((button) => {
  button.addEventListener("click", () => {
    setScreen(button.dataset.shortcut);
  });
});

document.querySelectorAll(".filter-chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    chip.classList.toggle("is-active");
    chip.setAttribute("aria-pressed", chip.classList.contains("is-active").toString());
  });
});

document.querySelectorAll(".stage-tab").forEach((tab) => {
  tab.addEventListener("click", () => {
    document.querySelectorAll(".stage-tab").forEach((item) => {
      const isActive = item === tab;
      item.classList.toggle("is-active", isActive);
      item.setAttribute("aria-selected", isActive.toString());
    });
  });
});

document.querySelectorAll(".segmented button, .doc-tabs button").forEach((button) => {
  button.addEventListener("click", () => {
    const group = button.parentElement;
    if (!group) return;
    group.querySelectorAll("button").forEach((item) => {
      item.classList.toggle("is-active", item === button);
    });
  });
});

setScreen("overview");
