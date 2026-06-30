# iOSApp3 — Canadian Museum of Nature Explorer

A SwiftUI iOS app for browsing curated museum specimens and performing **live global biodiversity search** using the GBIF API.

---

## ✨ Highlights

- 🗺️ **Interactive Museum Map**
  - Browse floors and galleries with tappable gallery pins.
- 🧬 **Curated Collection**
  - 7 galleries × 12 specimens each (84 curated records total).
- 🌍 **Live Global Search (GBIF)**
  - Non-empty search queries fetch live GBIF occurrence records.
  - Results are filtered to true GBIF occurrence IDs (`gbif_occ_*`) to prevent curated-only leakage.
- 🖼️ **Robust Image Fallback Chain**
  1. Local bundled image (if available)
  2. Curated image URL (`SpecimenImageCatalogue`)
  3. GBIF occurrence media
  4. Wikipedia image fallback
  5. Themed placeholder
- 📄 **Detail Sheets**
  - Taxonomy, facts, descriptions, and source links per specimen.

---

## 🧱 Tech Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Concurrency:** async/await + actors
- **Networking:** `URLSession`
- **APIs:**
  - [GBIF](https://www.gbif.org/developer/summary)
    - `/species/suggest`
    - `/occurrence/search`
  - Wikipedia API (`pageimages`) for image fallback

---

## 📁 Suggested Project Structure

```text
iOSApp3/
  App/
    iOSApp3App.swift

  Models/
    DisplayItem.swift
    GBIFModels.swift

  Services/
    GBIFDiscoveryService.swift
    GBIFDiscoveryService+Search.swift
    GBIFDiscoveryService+GlobalSearch.swift
    GBIFImageService.swift
    WikipediaImageService.swift

  Views/
    Map/
      MuseumMapView.swift
    Gallery/
      GalleryDetailView.swift
      SpecimenImageView.swift
    Detail/
      MuseumSpecimenDetailView.swift
    Archive/
      LiveArchiveView.swift

  Resources/
    SpecimenImageCatalogue.swift
    SpecimenImageQueryResolver.swift
    Assets.xcassets
```
---

## 🚀 Run Locally

**Requirements**

- Xcode 15+
- iOS Simulator / iPhone running iOS 17+

**Steps**

1. Clone the repo:
   
```text
git clone https://github.com/vibrant-impact/iOSApp3.git
cd iOSApp3
```

2. Open in Xcode:

```text
open iOSApp3.xcodeproj
```

3. Select a simulator and run (⌘R).

---

## 🔎 Search Behavior

- **Empty search query:** shows curated specimens for the active gallery.
- **Non-empty search query:** runs live global GBIF search.
- Global search currently:
  1. Resolves best taxon via species/suggest
  2. Searches occurrences by taxonKey + images
  3. Falls back to text query when needed

---

## 📝 Notes

- Some simulator logs like `UIAccessibilityLoaderWebShared` are runtime noise from Simulator and not app logic errors.
- Network-dependent features (GBIF/Wikipedia image fetch) may vary by connectivity and upstream response quality.

---

## 🙌 Acknowledgements

- Data services: **GBIF API**
- Supplemental media fallback: **Wikipedia API**
- Curated exhibit inspiration: Canadian Museum of Nature-style gallery organization
