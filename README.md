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


