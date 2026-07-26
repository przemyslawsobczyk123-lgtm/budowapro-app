# Stage guidance source register

Status: content version `4`, verified on `2026-07-26`.

The in-app guidance is an offline decision checklist. It does not replace a
construction design, geotechnical assessment, product system specification or
the decisions of the designer and site manager.

## Editorial rules

- State the moment when a decision becomes expensive or impossible to reverse.
- Use questions and inspection points, not universal execution instructions.
- Mark dimensions and product layouts as examples unless a project or selected
  system makes them binding.
- Keep legal requirements, standards and manufacturer system instructions
  distinct.
- Never present XPS or a dimpled membrane as the primary waterproofing layer.
- Never present drainage as mandatory without water conditions, a design and a
  valid discharge route.
- Never present one conductor size, earth resistance, ring layout or number of
  vertical electrodes as correct for every building.
- Present a ring earth electrode or vertical electrodes as designed options,
  not automatic repairs for an omitted foundation earth electrode.
- Treat `stan surowy otwarty` and `stan surowy zamkniety` as project workflow
  stages, not terms with one statutory definition.
- Never publish one universal construction-gate width, formwork removal time,
  installation test pressure/time or substrate-moisture limit.
- Keep foundation selection with the adapting/structural designer. The site
  manager receives and executes the approved design.
- Show the catalog version and verification date in every guidance detail.
- Store each source with a stable key, type, title, revision, URL and
  verification date.
- Preserve user notes and checklist state when the built-in catalog changes.

## Primary and official references

| Area | Reference | Use in BudowaPRO |
| --- | --- | --- |
| Construction start | [Construction Law, consolidated text Dz.U. 2026 item 524](https://api.sejm.gov.pl/eli/acts/DU/2026/524/text.pdf) | Separates document preparation from preparatory work that can legally start construction, including site development, temporary objects, connections and surveying. |
| Procedures and current forms | [GUNB procedures](https://www.gunb.gov.pl/strona/procedury-budowlane) and [GUNB forms](https://www.gov.pl/web/gunb/wzory-wnioskow-zgloszen-i-zawiadomien) | Keeps permit, notification and commencement prompts tied to current official procedures instead of embedding a fixed form version. |
| Spatial planning | [MRiT: spatial-planning reform](https://www.gov.pl/web/rozwoj-technologia/reforma-planowania-przestrzennego-2) | Prompts the investor to confirm the current MPZP/WZ route with the municipality; the app does not predict local planning status. |
| Surveying | [Budowlane ABC: geodetic activities and studies](https://budowlaneabc.gov.pl/praktyczny-przewodnik-inwestora/wnioski-elektroniczne/czynnosci-i-opracowania-geodezyjne/) | Supports commissioning the design map and construction setting-out to qualified professionals. |
| Ground conditions | [Regulation Dz.U. 2012 item 463](https://eli.gov.pl/api/acts/DU/2012/463/text.html) and [PN-EN 1997-1:2025-10 scope at PKN](https://sklep.pkn.pl/pn-en-1997-1-2025-10e.html) | Keeps investigation scope and geotechnical category with the designer and qualified geotechnical professional. |
| Construction log | [GUNB Electronic Construction Log](https://e-dziennikbudowy.gunb.gov.pl/) | Links users to the official EDB service without treating the app checklist as a statutory construction log. |
| Site organization and safety | [Construction-site safety regulation, Dz.U. 2003 item 401](https://eli.gov.pl/eli/DU/2003/401/ogl) and [PIP construction checklist](https://www.pip.gov.pl/publikacje/publikacje-dla-pracodawcow/bezpiecznie-i-zgodnie-z-prawem-lista-kontrolna-z-komentarezem) | Covers fencing, roads and walkways, temporary utilities, hygienic facilities and dangerous-zone controls in compact site-preparation prompts. |
| Access from a public road | [GDDKiA: exits](https://www.gov.pl/web/gddkia/zjazdy) | Reminds the user that a temporary or permanent site entrance may need road-administrator verification. |
| Current regulation register | [MRiT: Warunki techniczne and amendment list](https://budowlaneabc.gov.pl/praktyczny-przewodnik-inwestora/najwazniejsze-przepisy/warunki-techniczne/) | The app links to the official register because the 2022 consolidated text has later amendments. Content review must check this list before publication. |
| Moisture and groundwater | [2022 consolidated Warunki techniczne, sections 315-318](https://eli.gov.pl/api/acts/DU/2022/1225/text.html) | The building must be protected against precipitation, groundwater, surface water and capillary moisture; the solution depends on site conditions. |
| Water and sewer installations | [2022 consolidated Warunki techniczne, sections 113-127](https://eli.gov.pl/api/acts/DU/2022/1225/text.html) | Prompts for coordinated water, sewer, riser and inspection-point design before concrete. |
| Electrical installations | [2022 consolidated Warunki techniczne, sections 183-187](https://eli.gov.pl/api/acts/DU/2022/1225/text.html) | Section 184 identifies metal building structures, foundation reinforcement and metal elements in unreinforced foundations as earth electrodes for the electrical installation. It does not define one universal conductor or acceptance resistance. |
| Earthing | [PN-HD 60364-5-54 with A1:2023-04 scope at PKN](https://sklep.pkn.pl/pn-hd-60364-5-54-2011-a1-2023-04p.html) | The app points to an electrical design and compliant earthing/protective conductor selection; it does not reproduce the standard. |
| Initial verification | [PN-HD 60364-6:2016-07 scope at PKN](https://sklep.pkn.pl/pn-hd-60364-6-2016-07p.html) | Supports inspection, testing and recording results after installation. The acceptance criterion still comes from the designed protective measure and applicable requirements. |
| Lightning protection system | [PN-EN IEC 62305-3:2025-09 scope at PKN](https://sklep.pkn.pl/pn-en-iec-62305-3-2025-09e.html) | Applies when an LPS is designed and covers design, installation, inspection and maintenance. The app does not treat every house as requiring the same LPS or earth-electrode layout. |
| Lightning protection connections | [PN-EN 62561-1 scope and replacement at PKN](https://sklep.pkn.pl/normy/pn-en-62561-1-2017-07p.html) | The PKN record is used to identify the current replacement edition; the app does not reproduce normative requirements. |
| Lightning protection conductors | [PN-EN IEC 62561-2 scope at PKN](https://sklep.pkn.pl/pn-en-iec-62561-2-2018-04p.html) | Supports the prompt to select compliant conductor and earth-electrode components through the electrical design. |
| Below-ground waterproofing | [ITB: Izolacje przeciwwilgociowe i wodochronne czesci podziemnych budynkow](https://www.itb.pl/aktualnosci/izolacje-przeciwwilgociowe-i-wodochronne-czesci-podziemnych-budynkow/) | Separates damp-proofing from waterproofing and requires selection from water exposure and substrate conditions. |
| PMBC product scope | [PN-EN 15814 scope at PKN](https://sklep.pkn.pl/pn-en-15814-a2-2015-02e.html) | Identifies the product family; the selected system data sheet still controls application and dry-layer requirements. |
| Concrete execution | [PN-EN 13670:2011 with Ap1:2026-04 scope at PKN](https://sklep.pkn.pl/pn-en-13670-2011p.html) | Supports pre-concreting checks and execution control. The app does not publish a universal formwork-removal date. |
| Masonry execution | [PN-EN 1996-2:2010 scope at PKN](https://sklep.pkn.pl/pn-en-1996-2-2010p.html) | Supports project-based control of masonry execution, geometry and temporary stability. |
| Roof coverings | [ITB: Pokrycia dachowe, part C, booklet 1, 2024](https://www.itb.pl/aktualnosci/pokrycia-dachowe/) | Keeps roof checks tied to documentation, substrate, covering, penetrations and acceptance. ITB states that the recommendations are technical assistance, not binding regulations. |
| External windows and doors | [PN-EN 14351-1+A2:2016-10 scope at PKN](https://sklep.pkn.pl/pn-en-14351-1-a2-2016-10e.html) | Supports checking declared product performance. Installation support, fastening and sealing still come from the project and the selected installation system. |
| Window and balcony-door installation | [ITB source register for WTWiORB B6/2016](https://www.itb.pl/odbiory/) | Supports installation and acceptance prompts for fastening, support and sealing. The project and the selected system documentation remain controlling. |
| Water installations | [PN-EN 806-4:2010 scope at PKN](https://sklep.pkn.pl/pn-en-806-4-2010e.html) | Supports installation and commissioning prompts without copying one pressure or duration to every pipe system. |
| Surface heating | [PN-EN 1264-4:2021-10 scope at PKN](https://sklep.pkn.pl/pn-en-1264-4-2021-10e.html) | Supports installation and pre-screed checks for embedded heating/cooling systems. Project and system documentation control the actual procedure. |
| Ventilation acceptance | [PN-EN 12599:2013-04 scope at PKN](https://sklep.pkn.pl/normy/pn-en-12599-2013-04e.html) | Supports inspection and measurement prompts for completed ventilation and air-conditioning installations. |
| Ceramic finishes | [ITB: Okladziny i posadzki z plytek ceramicznych, part B, booklet 5, 2023](https://www.itb.pl/aktualnosci/okladziny-i-posadzki-z-plytek-ceramicznych/) | Supports checking project documentation, substrates, materials and hidden work before accepting ceramic finishes. |
| Liquid-applied waterproofing below tiles | [PN-EN 14891:2017-03 scope at PKN](https://sklep.pkn.pl/pn-en-14891-2017-03p.html) | Identifies the product family and declared performance. It does not replace design or installation instructions for corners, drains and penetrations. |
| Wet-area waterproofing execution | [ITB WTWiORB C6/2023](https://www.itb.pl/aktualnosci/zabezpieczenia-wodochronne-pomieszczen-mokrych/) | Supports execution and acceptance prompts for waterproofing layers in wet rooms, including system details and documentation. |

## System and execution references

These references are examples of complete systems and inspection details. They
are not legal requirements and must not be mixed into a new system without
compatibility confirmation.

| Area | Reference | Editorial limitation |
| --- | --- | --- |
| Foundation, ring and retrofit earthing | [DEHN: Uziomy fundamentowe](https://www.dehn.pl/sites/default/files/media/files/ds162_uziomy_fundamentowe_pl.pdf) and [DEHN: foundation and ring earth electrodes](https://www.dehn.pl/pl/uziemienie) | Explains why an electrically isolated foundation may require a ring earth electrode and shows ring or vertical electrodes as retrofit options. Dimensions and layouts in the guide are system examples, not universal Polish requirements. The guide also references German DIN 18014. |
| Building entries | [Hauff-Technik: przepusty do budynkow](https://www.hauff-technik.pl/pl/kategoria/przepusty-do-budynkow-3/przepusty-do-budynkow-59) | Supports prompts for planned sleeves and water/gas-tight system seals; exact type and size come from the project. |
| Two-component waterproofing | [Remmers MB 2K system sequence](https://www.remmers.pl/pl/hydroizolacja-zewnetrzna-MB2K) | Supports substrate, detail, first/second layer and compatibility checks. It does not make one product correct for every water exposure. |
| XPS at foundations | [URSA: foundation wall application](https://www.ursa.pl/pl-pl/zastosowania/sciany-fundamentowe/) | XPS is shown as thermal/protective insulation used with waterproofing selected for the actual ground-water conditions. |
| External shading | [ALUPROF system compendium](https://aluprof.com/files/downloads/Kompendium%20wiedzy%20o%20systemach_PL.pdf) | Box, guide and recess dimensions are system-specific. The app explicitly rejects a universal `5 cm` lintel recess. |

## Review cadence

Review the source register when:

- construction regulations or referenced standards change,
- a catalog item changes meaning or adds a numeric example,
- a manufacturer removes or supersedes a linked technical document,
- the content version is increased.
