//
//  GBIFDiscoveryService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-27.
//

import Foundation
import SwiftUI

// MARK: - Canadian Museum of Nature Map Galleries
/// Supported museum galleries (exhibit groupings) used for curated browsing.
enum MuseumGallery: String, CaseIterable, Identifiable {
    case bugs = "Bugs Alive"               // Level 0
    case fossils = "Fossil Gallery"        // Level 1
    case water = "Water Gallery"           // Level 2
    case mammals = "Mammal Gallery"       // Level 2
    case earth = "Earth Gallery"           // Level 3
    case birds = "Bird Gallery"            // Level 3
    case arctic = "Canada Goose Arctic"    // Level 4
    
    var id: String { self.rawValue }
    
    var floor: Int {
        switch self {
        case .bugs: return 0
        case .fossils: return 1
        case .water, .mammals: return 2
        case .earth, .birds: return 3
        case .arctic: return 4
        }
    }
    
    var icon: String {
        switch self {
        case .bugs: return "ladybug.fill"
        case .fossils: return "sparkles"
        case .water: return "fish.fill"
        case .mammals: return "pawprint.fill"
        case .earth: return "globe.americas.fill"
        case .birds: return "bird.fill"
        case .arctic: return "snowflake"
        }
    }
    
    var color: Color {
        switch self {
        case .bugs: return .green
        case .fossils: return .orange
        case .water: return .blue
        case .mammals: return .brown
        case .earth: return .purple
        case .birds: return .red
        case .arctic: return .teal
        }
    }
    
    var galleryDescription: String {
        switch self {
        case .bugs: return "Creepy-crawly live leafcutter ants, beetles, and arachnids."
        case .fossils: return "Canada's premier dinosaur skull fossils including Daspletosaurus skeletons."
        case .water: return "A 19.8-metre blue whale skeleton and diverse marine species."
        case .mammals: return "Canada's iconic wild mammals rendered in life-size diorama scenes."
        case .earth: return "World-class collection of glittering minerals, crystals, and meteorites."
        case .birds: return "Over 500 beautifully preserved Canadian avian species."
        case .arctic: return "A cultural and natural historical journey across Canada's icy northlands."
        }
    }
}

// MARK: - Main Registry Discovery Service
/// Primary data service for curated museum records.
class GBIFDiscoveryService {
    static let shared = GBIFDiscoveryService()
    private init() {}
    
    /// Returns curated specimens.
    ///
    /// - Parameters:
    ///   - gallery: Active gallery when `query` is empty.
    ///   - query: Optional local text filter over curated dataset.
    /// - Returns: Curated gallery items or filtered museum-wide curated items.
    func fetchGallerySpecimens(gallery: MuseumGallery, query: String = "") -> [DisplayItem] {
        let allItems = getCuratedMasterDatabase()
        
        if query.isEmpty {
            // Context-Aware: Returns purely the active gallery's 12 curated specimens
            let prefix = resolveGalleryPrefix(for: gallery)
            return allItems.filter { $0.id.hasPrefix(prefix) }
        } else {
            // Museum-Wide: Automatically searches all 84 items across every gallery in the museum
            let lowerQuery = query.lowercased()
            return allItems.filter { item in
                let matchesCommonName = item.title.lowercased().contains(lowerQuery)
                let matchesScientificName = (item.gbifData?.scientificName ?? "").lowercased().contains(lowerQuery)
                let matchesDescription = item.detailedDescription.lowercased().contains(lowerQuery)
                let matchesFamily = (item.gbifData?.family ?? "").lowercased().contains(lowerQuery)
                let matchesAttribution = item.attributionText.lowercased().contains(lowerQuery)
                
                return matchesCommonName || matchesScientificName || matchesDescription || matchesFamily || matchesAttribution
            }
        }
    }
    
    /// Maps a gallery enum to its canonical curated ID prefix.
    func resolveGalleryPrefix(for gallery: MuseumGallery) -> String {
        switch gallery {
        case .bugs: return "bug_"
        case .fossils: return "fos_"
        case .water: return "wat_"
        case .mammals: return "mam_"
        case .earth: return "ear_"
        case .birds: return "bir_"
        case .arctic: return "arc_"
        }
    }
    
    /// Resolves a curated gallery from a specimen ID prefix.
    func resolveGalleryFromId(_ id: String) -> MuseumGallery {
        if id.hasPrefix("bug_") { return .bugs }
        if id.hasPrefix("fos_") { return .fossils }
        if id.hasPrefix("wat_") { return .water }
        if id.hasPrefix("mam_") { return .mammals }
        if id.hasPrefix("ear_") { return .earth }
        if id.hasPrefix("bir_") { return .birds }
        return .arctic
    }
    
    /// Builds the full in-memory curated dataset by combining all gallery slices.
    private func getCuratedMasterDatabase() -> [DisplayItem] {
        var allItems: [DisplayItem] = []
        allItems.append(contentsOf: getBugsAliveSpecs())
        allItems.append(contentsOf: getFossilSpecs())
        allItems.append(contentsOf: getWaterSpecs())
        allItems.append(contentsOf: getMammalSpecs())
        allItems.append(contentsOf: getEarthSpecs())
        allItems.append(contentsOf: getBirdSpecs())
        allItems.append(contentsOf: getArcticSpecs())
        return allItems
    }
    
    // MARK: - Level 0: Bugs Alive Data (12 Items)
    private func getBugsAliveSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "bug_1", title: "Leafcutter Ants",
                shortDescription: "The undisputed stars of the hall, marching across aerial tubes.",
                detailedDescription: "Visitors can watch thousands of live ants marching across clear aerial tubes, carrying cut foliage to cultivate their subterranean fungus gardens. They function as organic farmers.",
                funFacts: ["Centerpiece of Bugs Alive", "Agriculture: Cultivate subterranean fungus", "Transport: Can carry 20x their weight"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1551024739-78e9d60c45ca?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1018241477"), attributionText: "CMN Bugs Vivarium",
                gbifData: GBIFData(usageKey: nil, scientificName: "Atta cephalotes", canonicalName: "Leafcutter Ant", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Hymenoptera", family: "Formicidae", genus: "Atta")
            ),
            DisplayItem(
                id: "bug_2", title: "Rose-Haired Tarantula",
                shortDescription: "A large, docile arachnid illustrating spider defense anatomy.",
                detailedDescription: "A large terrestrial arachnid specimen that serves as a prime example of biological sensory hairs, defense structures, and predatory hunting capabilities.",
                funFacts: ["Origin: Chile, South America", "Lifespan: Females can live over 20 years", "Defense: Kicks urticating hairs from abdomen"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1004124355"), attributionText: "CMN Live Arachnids",
                gbifData: GBIFData(usageKey: nil, scientificName: "Grammostola rosea", canonicalName: "Rose-Haired Tarantula", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Arachnida", order: "Araneae", family: "Theraphosidae", genus: "Grammostola")
            ),
            DisplayItem(
                id: "bug_3", title: "Salmon Pink Bird-Eating Tarantula",
                shortDescription: "One of the largest spider species, displaying immense scale.",
                detailedDescription: "A spectacular showcase spider highlighting the massive scale tropical arachnids can reach. Known to prey on small vertebrates in native Brazilian forests.",
                funFacts: ["Size: Third largest tarantula globally", "Legspan: Up to 11 inches (28 cm)", "Venom: Mild, but fangs are physically massive"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1559828453-6dec0786cf88?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1041124115"), attributionText: "CMN Terrestrial Vault",
                gbifData: GBIFData(usageKey: nil, scientificName: "Lasiodora parahybana", canonicalName: "Salmon Pink Bird-Eating Tarantula", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Arachnida", order: "Araneae", family: "Theraphosidae", genus: "Lasiodora")
            ),
            DisplayItem(
                id: "bug_4", title: "Madagascar Hissing Cockroach",
                shortDescription: "Highly active insects utilizing abdominal spiracles to hiss.",
                detailedDescription: "A robust wingless insect that forces air out of specialized abdominal respiratory spiracles to produce a loud warning hiss to startle predators.",
                funFacts: ["Mechanism: No vocal cords; uses abdominal air valves", "Role: Essential forest floor recycler", "Social Hierarchy: Males fight using large horns"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1541185933-ef5d8ed016c2?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1043128912"), attributionText: "CMN Live Vivarium Display",
                gbifData: GBIFData(usageKey: nil, scientificName: "Gromphadorhina portentosa", canonicalName: "Madagascar Hissing Cockroach", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Blattodea", family: "Blaberidae", genus: "Gromphadorhina")
            ),
            DisplayItem(
                id: "bug_5", title: "Asian Forest Scorpion",
                shortDescription: "Glossy, deep-black scorpion demonstrating protective exoskeleton shell chitin.",
                detailedDescription: "A striking forest arachnid showing sensory peg-like organs called pectines, powerful hunting pincers, and a heavy carbon-composite exoskeleton.",
                funFacts: ["Glows under UV light (Fluorescence)", "Pincers: Uses crushing strength over venom strength", "Habitat: Tropical Asian rainforest floor layers"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1613143242095-2eb4d5718df2?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1312351233"), attributionText: "CMN Exoskeleton Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Heterometrus spinifer", canonicalName: "Asian Forest Scorpion", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Arachnida", order: "Scorpiones", family: "Scorpionidae", genus: "Heterometrus")
            ),
            DisplayItem(
                id: "bug_6", title: "Horrid King Assassin Bug",
                shortDescription: "Vivid warning colors warning of its piercing dissolving saliva.",
                detailedDescription: "A predatory insect displaying bold orange-yellow warning coloration (Aposematism) and a specialized piercing proboscis used to inject liquefying enzymes into prey.",
                funFacts: ["Size: One of the largest assassin bug species", "Weapon: Powerful enzyme-injecting bite", "Defensive Spray: Can shoot burning spray if threatened"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1576176539998-0b37faf491e5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1123445582"), attributionText: "CMN Predatory Arthropod Lab",
                gbifData: GBIFData(usageKey: nil, scientificName: "Psytalla horrida", canonicalName: "Horrid King Assassin Bug", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Hemiptera", family: "Reduviidae", genus: "Psytalla")
            ),
            DisplayItem(
                id: "bug_7", title: "Malayan Jungle Nymph",
                shortDescription: "A massive, heavy-bodied live stick insect mimicking bright green leaves.",
                detailedDescription: "The ultimate camouflaged canopy insect. Perfectly mimics bright green, serrated forest leaves to remain invisible to insectivorous predators.",
                funFacts: ["Heaviest stick insect species in the world", "Wings: Make loud rustling defense sounds", "Aggression: Highly defensive; uses spiny back legs"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1876543213"), attributionText: "CMN Canopy Camouflage Vault",
                gbifData: GBIFData(usageKey: nil, scientificName: "Heteropteryx dilatata", canonicalName: "Malayan Jungle Nymph", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Phasmatodea", family: "Heteropterygidae", genus: "Heteropteryx")
            ),
            DisplayItem(
                id: "bug_8", title: "Thorny Devil Stick Insect",
                shortDescription: "Armored, bark-colored insect covered in sharp spines.",
                detailedDescription: "A ground-dwelling stick insect covered in hard, sharp spines mimicking dead pine wood and forest detritus. Extremely resilient defense shell.",
                funFacts: ["Defense: Squeezes predators with hind leg spines", "Color: Dark woody bark camouflage", "Habit: Nocturnal ground-dwelling organism"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1548676924-48e71ceac151?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1283749455"), attributionText: "CMN Entomology Collection",
                gbifData: GBIFData(usageKey: nil, scientificName: "Eurycantha calcarata", canonicalName: "Thorny Devil Stick Insect", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Phasmatodea", family: "Phasmatidae", genus: "Eurycantha")
            ),
            DisplayItem(
                id: "bug_9", title: "Giant Leaf Katydid",
                shortDescription: "A master leaf mimic featuring realistic leaf vein details.",
                detailedDescription: "Leaf-mimicking master insect featuring realistic vein patterns, leaf-like margins, and brown decay spots across wings to mimic decaying foliage.",
                funFacts: ["Veins: Mimics actual photosynthetic leaf capillaries", "Calls: High-frequency ultrasonic vibrations", "Armor: Flattened structures for hiding"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1982736455"), attributionText: "CMN Mimicry Display",
                gbifData: GBIFData(usageKey: nil, scientificName: "Pseudophyllus titan", canonicalName: "Giant Leaf Katydid", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Orthoptera", family: "Tettigoniidae", genus: "Pseudophyllus")
            ),
            DisplayItem(
                id: "bug_10", title: "Blue Death-Feigning Beetle",
                shortDescription: "Desert beetle utilizing waxy moisture-saving coating.",
                detailedDescription: "A hardy desert-dwelling beetle known for its pale blue waxy coating (preventing water loss) and its defensive reflex of rolling onto its back.",
                funFacts: ["Wax: Secretes blue powder reflecting solar heat", "Behavior: Plays dead until threats pass", "Water: Survives without drinking; absorbs humidity"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1571171637578-41bc2dd4dcd2?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1283746221"), attributionText: "CMN Arid Soils Terrarium",
                gbifData: GBIFData(usageKey: nil, scientificName: "Asbolus verrucosus", canonicalName: "Blue Death-Feigning Beetle", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Coleoptera", family: "Tenebrionidae", genus: "Asbolus")
            ),
            DisplayItem(
                id: "bug_11", title: "Giant Hercules Beetle Model",
                shortDescription: "A massive, anatomically accurate climbable beetle sculpture.",
                detailedDescription: "A larger-than-life model of a male Hercules beetle, highlighting its massive thoracic horn structure. Designed for physical, interactive play.",
                funFacts: ["Climbable interactive kid museum landmark", "Horns: Thoracic pincers used to fight rivals", "Scale: 15x actual size"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1004124355"), attributionText: "CMN Interactive Exhibits",
                gbifData: GBIFData(usageKey: nil, scientificName: "Dynastes hercules", canonicalName: "Hercules Beetle", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Coleoptera", family: "Scarabaeidae", genus: "Dynastes")
            ),
            DisplayItem(
                id: "bug_12", title: "Micro-Eye Preserved Beetles",
                shortDescription: "Precision interactive magnifiers displaying iridescent colors.",
                detailedDescription: "A rotating station of beautifully preserved scarab and weevil specimens positioned under visitor-operated micro-eye digital magnifiers.",
                funFacts: ["Structure: Micro-carapace reflects light without pigments", "Interactive: 50x mechanical magnification", "Rarity: Features rare metallic weevils from Quebec"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1041124115"), attributionText: "CMN Microscopy Lab",
                gbifData: GBIFData(usageKey: nil, scientificName: "Curculionidae gen.", canonicalName: "Weevils", rank: "Family", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Insecta", order: "Coleoptera", family: "Curculionidae", genus: nil)
            )
        ]
    }
    
    // MARK: - Level 1: Fossil Gallery Data (12 Items)
    private func getFossilSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "fos_1", title: "Daspletosaurus",
                shortDescription: "Centerpiece holotype dinosaur skeleton in the main gallery path.",
                detailedDescription: "A nearly complete skeletal mount of an earlier, multi-tonne cousin of Tyrannosaurus rex. It is the official species holotype used to first define the species.",
                funFacts: ["Holotype: Official science reference fossil", "Origin: Red Deer River, Alberta", "Length: 9 Meters from snout to tail"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124112"), attributionText: "CMN Paleobiology Collection",
                gbifData: GBIFData(usageKey: nil, scientificName: "Daspletosaurus torosus", canonicalName: "Daspletosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Tyrannosauridae", genus: "Daspletosaurus")
            ),
            DisplayItem(
                id: "fos_2", title: "Edmontosaurus",
                shortDescription: "First dinosaur skeleton displayed to the public in Canada.",
                detailedDescription: "A massive, panel-mounted duck-billed dinosaur from the Alberta badlands. Excavated in 1912 and displayed continuously since 1913.",
                funFacts: ["Historic Landmark: Exhibited since 1913", "Fossil State: 90% authentic fossilized bones", "Height: Approx. 4 meters in display panel"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124113"), attributionText: "CMN Vertebrate Paleontological Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Edmontosaurus regalis", canonicalName: "Edmontosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Hadrosauridae", genus: "Edmontosaurus")
            ),
            DisplayItem(
                id: "fos_3", title: "Triceratops Skull",
                shortDescription: "A dense, massive late-Cretaceous horned dinosaur skull.",
                detailedDescription: "An exceptional, highly compressed original skull and skeletal assembly excavated over half a century ago, displaying three stout horns.",
                funFacts: ["Scale: Heavy bone structures weighing over 300 kg", "Horns: Protective skull spikes", "Age: Approx. 66 million years old"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1532187863486-abf9d39d66e8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124114"), attributionText: "CMN Red Deer River Collection",
                gbifData: GBIFData(usageKey: nil, scientificName: "Triceratops prorsus", canonicalName: "Triceratops", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Ceratopsidae", genus: "Triceratops")
            ),
            DisplayItem(
                id: "fos_4", title: "Styracosaurus",
                shortDescription: "Spiked frill ceratopsian specimen (CMNFV 344) holotype.",
                detailedDescription: "A signature Canadian horned dinosaur specimen featuring a massive skull frill lined with long, formidable spikes. Discovered by Charles Sternberg.",
                funFacts: ["Spikes: Six long defensive spikes on frill", "Holotype: CMNFV 344", "Year: 1913 Discovery"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1606856110002-d5994a503083?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124115"), attributionText: "CMN Cretaceous Alberta Expedition",
                gbifData: GBIFData(usageKey: nil, scientificName: "Styracosaurus albertensis", canonicalName: "Styracosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Ceratopsidae", genus: "Styracosaurus")
            ),
            DisplayItem(
                id: "fos_5", title: "Chasmosaurus",
                shortDescription: "A horned dinosaur showing a large open-windowed bone frill.",
                detailedDescription: "A beautifully preserved horned dinosaur skull displaying a large, broad frill with large open windows mapped to reduce head weight.",
                funFacts: ["Frill: Open-windowed structures used to save weight", "Origin: Dinosaur Park Formation", "Weighed: Up to 2 tonnes in life"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124116"), attributionText: "CMN Historic Dino Hall",
                gbifData: GBIFData(usageKey: nil, scientificName: "Chasmosaurus belli", canonicalName: "Chasmosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Ceratopsidae", genus: "Chasmosaurus")
            ),
            DisplayItem(
                id: "fos_6", title: "Spiclypeus (Nick-Named 'Judith')",
                shortDescription: "Newly described horned species holotype showing curved horns.",
                detailedDescription: "The scientifically vital holotype skull representing a newly described horned species. Recovered with deep pathologies in its limb bones.",
                funFacts: ["Nick-name: 'Judith'", "Horns: Curving outwards over the eyes", "Rarity: Displays joint bone infection scars"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1516467508483-a7212febe31a?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124117"), attributionText: "CMN Judith Basin Expeditions",
                gbifData: GBIFData(usageKey: nil, scientificName: "Spiclypeus shipporum", canonicalName: "Spiclypeus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Dinosauria", family: "Ceratopsidae", genus: "Spiclypeus")
            ),
            DisplayItem(
                id: "fos_7", title: "Elasmosaurus",
                shortDescription: "Long-necked Marine Reptile with a highly flexible neck.",
                detailedDescription: "An impossibly long-necked plesiosaur that dominated ancient oceans while dinosaurs walked the land. Features flattened paddle limbs.",
                funFacts: ["Neck: Composed of 71 vertebrae segments", "Role: Ambush marine hunter", "Habitat: Western Interior Seaway"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124118"), attributionText: "CMN Marine Vertebrate Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Elasmosaurus platyurus", canonicalName: "Elasmosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Plesiosauria", family: "Elasmosauridae", genus: "Elasmosaurus")
            ),
            DisplayItem(
                id: "fos_8", title: "Platecarpus (Mosasaur)",
                shortDescription: "Sleek and powerful ancient marine lizard.",
                detailedDescription: "A sleek, predatory marine lizard specimen boasting paddle-like limbs, a shark-like tail fin, and sharp conical teeth for catching prey.",
                funFacts: ["Skin: Preserved scale impressions found", "Teeth: Curved backwards to prevent prey escape", "Size: Over 4.3 meters long"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124119"), attributionText: "CMN Western Seaway",
                gbifData: GBIFData(usageKey: nil, scientificName: "Platecarpus coryphaeus", canonicalName: "Platecarpus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Squamata", family: "Mosasauridae", genus: "Platecarpus")
            ),
            DisplayItem(
                id: "fos_9", title: "Champsosaurus",
                shortDescription: "Flat, crocodile-mimic marsh specialist.",
                detailedDescription: "A beautifully flat, complete skeleton of a freshwater reptile that hunted swamps alongside late Cretaceous dinosaurs.",
                funFacts: ["Form: Reumbles modern gavials", "Adapative: Survived the KT mass extinction", "Chitin: Heavily jawed fish-eater"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1504198453319-5ce911bafcde?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124120"), attributionText: "CMN Badlands Freshwater",
                gbifData: GBIFData(usageKey: nil, scientificName: "Champsosaurus annectens", canonicalName: "Champsosaurus", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Choristodera", family: "Champsosauridae", genus: "Champsosaurus")
            ),
            DisplayItem(
                id: "fos_10", title: "Tiktaalik roseae",
                shortDescription: "The iconic transitional fish-to-amphibian fossil.",
                detailedDescription: "A 375-million-year-old transitional fossil representing the shift from aquatic fish fins to jointed limbs adaptation for walking.",
                funFacts: ["Crown jewel of transitional paleontology", "Discovered: Ellesmere Island, Nunavut", "Age: 375 Million Years Old"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1517783999520-f068d7431a60?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124121"), attributionText: "CMN Nunavut Project",
                gbifData: GBIFData(usageKey: nil, scientificName: "Tiktaalik roseae", canonicalName: "Tiktaalik", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Sarcopterygii", order: "Elpistostegalia", family: "Elpistostegidae", genus: "Tiktaalik")
            ),
            DisplayItem(
                id: "fos_11", title: "High-Arctic Camel",
                shortDescription: "Three million year old giant Ellesmere Island camel.",
                detailedDescription: "Rare fossilized bone fragments of a prehistoric camel found in Canada's north, proving the high Arctic was once home to lush forests.",
                funFacts: ["Size: 30% larger than modern camels", "Antiquity: 3.5 Million Years Old", "Adaptation: Eyes suited for dark winters"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124122"), attributionText: "CMN Arctic Expedition",
                gbifData: GBIFData(usageKey: nil, scientificName: "Camelops dromedarius", canonicalName: "Camelops", rank: "Genus", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Camelidae", genus: "Camelops")
            ),
            DisplayItem(
                id: "fos_12", title: "Woolly Mammoth",
                shortDescription: "Genuine cranium with large curling ivory tusks.",
                detailedDescription: "An excellent cranial fossil showing massive sweeping tusks from a woolly mammoth. Recovered from the Yukon ice-age sediment layers.",
                funFacts: ["Age: Pleistocene Ice Age Megafauna", "Tusks: Curved ivory up to 3 meters", "Diet: Tundra steppe grasses"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/2415124123"), attributionText: "CMN Quaternary Yukon Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Mammuthus primigenius", canonicalName: "Woolly Mammoth", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Proboscidea", family: "Elephantidae", genus: "Mammuthus")
            )
        ]
    }
    
    // MARK: - Level 2: Water Gallery Data (12 Items)
    private func getWaterSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "wat_1", title: "Blue Whale Skeleton",
                shortDescription: "Centerpiece 19.8-metre skeleton suspended in the gallery.",
                detailedDescription: "A breathtaking physical display representing the largest animal species ever to live. The skeleton is suspended from the ceiling to illustrate its immense scale.",
                funFacts: ["Length: 19.8 Meters (65 ft.)", "Rarity: One of three displays in Canada", "Origin: Atlantic Coastline"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495111"), attributionText: "CMN Suspended Exhibit",
                gbifData: GBIFData(usageKey: nil, scientificName: "Balaenoptera musculus", canonicalName: "Blue Whale", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Cetacea", family: "Balaenopteridae", genus: "Balaenoptera")
            ),
            DisplayItem(
                id: "wat_2", title: "Moon Jellyfish",
                shortDescription: "Translucent, glowing drifters in specialized circular tanks.",
                detailedDescription: "Housed in specialized circular tanks that maintain circular swimming currents (Kreisels) to keep these delicate invertebrates suspended.",
                funFacts: ["Body: 95% water, no brain or heart", "Display: Illuminated by active color-shift LEDs", "Status: Highly popular live display"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495112"), attributionText: "CMN Live Marine Tanks",
                gbifData: GBIFData(usageKey: nil, scientificName: "Aurelia aurita", canonicalName: "Moon Jellyfish", rank: "Species", kingdom: "Animalia", phylum: "Cnidaria", taxonomicClass: "Scyphozoa", order: "Semaeostomeae", family: "Ulmaridae", genus: "Aurelia")
            ),
            DisplayItem(
                id: "wat_3", title: "Ochre Sea Star",
                shortDescription: "Starfish showcasing suction-tipped tube feet.",
                detailedDescription: "Tide pool starfish that use suction-tipped water vascular feet to hold tight against crashing shoreline waves.",
                funFacts: ["Habitat: Intertidal rocky shores", "Keystone Species: Controls mussel populations", "Defense: Highly regenerative limbs"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495113"), attributionText: "CMN Pacific Tank",
                gbifData: GBIFData(usageKey: nil, scientificName: "Pisaster ochraceus", canonicalName: "Ochre Sea Star", rank: "Species", kingdom: "Animalia", phylum: "Echinodermata", taxonomicClass: "Asteroidea", order: "Forcipulatida", family: "Asteriidae", genus: "Pisaster")
            ),
            DisplayItem(
                id: "wat_4", title: "Spiky Sea Urchin",
                shortDescription: "Marine invertebrates covered in hard defensive spines.",
                detailedDescription: "Urchins covered in highly rigid, movable calcium carbonate spines. They graze on kelp beds off the Pacific coast.",
                funFacts: ["Teeth: Five self-sharpening teeth structures", "Role: Major kelp forest herbivore", "Protection: Heavy needle defense"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1504198453319-5ce911bafcde?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495114"), attributionText: "CMN Invertebrate Live",
                gbifData: GBIFData(usageKey: nil, scientificName: "Strongylocentrotus droebachiensis", canonicalName: "Green Sea Urchin", rank: "Species", kingdom: "Animalia", phylum: "Echinodermata", taxonomicClass: "Echinoidea", order: "Camarodonta", family: "Strongylocentrotidae", genus: "Strongylocentrotus")
            ),
            DisplayItem(
                id: "wat_5", title: "Giant Sea Cucumber",
                shortDescription: "Leathery bottom dwellers functioning as sea floor cleaners.",
                detailedDescription: "Detritivores that scour marine sediments, filtering and breaking down organic decaying matter along the seafloor.",
                funFacts: ["Defense: Can eject sticky defense threads", "Breathing: Respired through their cloaca", "Ecology: Major ocean floor recycling force"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1546026423-cc4642628d2b?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495115"), attributionText: "CMN Marine Invertebrate",
                gbifData: GBIFData(usageKey: nil, scientificName: "Parastichopus californicus", canonicalName: "California Sea Cucumber", rank: "Species", kingdom: "Animalia", phylum: "Echinodermata", taxonomicClass: "Holothuroidea", order: "Synallactida", family: "Stichopodidae", genus: "Parastichopus")
            ),
            DisplayItem(
                id: "wat_6", title: "Tentacled Anemone",
                shortDescription: "Predatory flower-like invertebrates with stinging cells.",
                detailedDescription: "Vibrant marine invertebrates resembling flowers that use stinging cells (nematocysts) in their tentacles to capture passing food.",
                funFacts: ["Sting: Captures tiny crabs and fish", "Attachment: Glues base to rocky shelves", "Longevity: Can survive in cool tanks for decades"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495116"), attributionText: "CMN Live Anemones",
                gbifData: GBIFData(usageKey: nil, scientificName: "Metridium farcimen", canonicalName: "Giant Plumose Anemone", rank: "Species", kingdom: "Animalia", phylum: "Cnidaria", taxonomicClass: "Anthozoa", order: "Actiniaria", family: "Metridiidae", genus: "Metridium")
            ),
            DisplayItem(
                id: "wat_7", title: "Spotted Turtle",
                shortDescription: "Endangered small species covered in bright yellow spots.",
                detailedDescription: "A small, endangered Canadian turtle. The museum's active specimens participate in a captive-breeding and conservation program.",
                funFacts: ["Scale: Unique yellow spots like stars", "Conservation: Captive-bred to bolster wild numbers", "Status: Highly protected in Ontario wetlands"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495117"), attributionText: "CMN Live Wetlands",
                gbifData: GBIFData(usageKey: nil, scientificName: "Clemmys guttata", canonicalName: "Spotted Turtle", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Reptilia", order: "Testudines", family: "Emydidae", genus: "Clemmys")
            ),
            DisplayItem(
                id: "wat_8", title: "Native River Predators",
                shortDescription: "Large freshwater predatory fish from northern lakes.",
                detailedDescription: "Large game fish from Canadian rivers housed in the gallery's massive 1,000-gallon freshwater river aquarium habitat.",
                funFacts: ["Aquarium: Largest river tank in the Ottawa valley", "Diet: Carnivorous ambush hunters", "Specimen: Features prominent northern Pike"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495118"), attributionText: "CMN 1,000 Gallon River Tank",
                gbifData: GBIFData(usageKey: nil, scientificName: "Esox lucius", canonicalName: "Northern Pike", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Actinopterygii", order: "Esociformes", family: "Esocidae", genus: "Esox")
            ),
            DisplayItem(
                id: "wat_9", title: "Sea Otter",
                shortDescription: "Taxidermy mount highlighting an essential keystone species.",
                detailedDescription: "A beautiful taxidermy display demonstrating how sea otters protect kelp forest ecosystems by feeding on sea urchins.",
                funFacts: ["Keystone Species: Keeps kelp beds safe", "Fur Density: Up to 1 million hairs per square inch", "Tool Usage: Uses stones to open shells"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495119"), attributionText: "CMN Taxidermy Archives",
                gbifData: GBIFData(usageKey: nil, scientificName: "Enhydra lutris", canonicalName: "Sea Otter", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Mustelidae", genus: "Enhydra")
            ),
            DisplayItem(
                id: "wat_10", title: "Pacific Dungeness Crab",
                shortDescription: "Hard-shelled marine crab from deep coastal bays.",
                detailedDescription: "An impressive, fully preserved outer shell of this economically critical crustacean. Features heavily serrated shell armor.",
                funFacts: ["Habitat: Deep cool waters in BC", "Diet: Clams, worms, and small fish", "Shell: Must molt regularly to grow"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1513553404607-988bf2703777?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495120"), attributionText: "CMN Coastal Crustaceans",
                gbifData: GBIFData(usageKey: nil, scientificName: "Metacarcinus magister", canonicalName: "Dungeness Crab", rank: "Species", kingdom: "Animalia", phylum: "Arthropoda", taxonomicClass: "Malacostraca", order: "Decapoda", family: "Cancridae", genus: "Metacarcinus")
            ),
            DisplayItem(
                id: "wat_11", title: "Marine Molluscs",
                shortDescription: "Diverse shell collections of coastal clams and snails.",
                detailedDescription: "A display of pristine shells from coastal clams, mussels, and scallops, illustrating how organisms build protective calcium armor.",
                funFacts: ["Material: Calcite and aragonite shell layers", "Ecology: Vulnerable to ocean acidification", "Collection: Sourced from the Atlantic Brunel dataset"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495121"), attributionText: "CMN Brunel Malacology",
                gbifData: GBIFData(usageKey: nil, scientificName: "Mytilus edulis", canonicalName: "Blue Mussel", rank: "Species", kingdom: "Animalia", phylum: "Mollusca", taxonomicClass: "Bivalvia", order: "Mytilida", family: "Mytilidae", genus: "Mytilus")
            ),
            DisplayItem(
                id: "wat_12", title: "Canadian Seabirds",
                shortDescription: "Taxidermy mounts showing evolutionary links to shorelines.",
                detailedDescription: "A selection of coastal seabirds highlighting adaptations for nesting on rocky cliffs and hunting in cool waters.",
                funFacts: ["Feathers: Waterproof outer coatings", "Nesting: Settle on steep vertical rock ridges", "Feet: Webbed feet for diving and steering"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/5123495122"), attributionText: "CMN Coastal Avian Exhibit",
                gbifData: GBIFData(usageKey: nil, scientificName: "Larus argentatus", canonicalName: "Herring Gull", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Charadriiformes", family: "Laridae", genus: "Larus")
            )
        ]
    }
    
    // MARK: - Level 2: Mammal Gallery Data (12 Items)
    private func getMammalSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "mam_1", title: "Plains Bison",
                shortDescription: "Massive centerpiece mount in the bison-wolf standoff.",
                detailedDescription: "An impressive, full-sized male bison taxidermy mount. Stands defensively alongside its herd in the museum's most famous and historic diorama.",
                funFacts: ["Diorama: Stand-off painted by Clarence Tillenius", "Historic: Mounted over 80 years ago", "Status: Icons of the Canadian prairie"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249512"), attributionText: "CMN Tillenius Prairie",
                gbifData: GBIFData(usageKey: nil, scientificName: "Bison bison", canonicalName: "Plains Bison", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Bovidae", genus: "Bison")
            ),
            DisplayItem(
                id: "mam_2", title: "Gray Wolf Pack",
                shortDescription: "Pack of wolves closing in on their bison prey.",
                detailedDescription: "A realistic pack of wolves positioned mid-hunt, actively closing in on the bison. The background depicts marshes in Wood Buffalo National Park.",
                funFacts: ["Painting: Exact geographic backdrop matching Alberta", "Dynamic: Captured mid-hunt action", "Unity: Shows pack coordination tactics"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1590424753046-cf121650f1e4?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249513"), attributionText: "CMN Tillenius Boreal",
                gbifData: GBIFData(usageKey: nil, scientificName: "Canis lupus", canonicalName: "Gray Wolf", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Canidae", genus: "Canis")
            ),
            DisplayItem(
                id: "mam_3", title: "Grizzly Bear",
                shortDescription: "Apex predator showing massive bone and claw structures.",
                detailedDescription: "An incredible male grizzly bear mount, displaying massive shoulder muscles, powerful jaws, and long claws optimized for digging.",
                funFacts: ["Claws: Long, blunt non-retractable claws", "Diet: Omnivorous; berries, roots, and salmon", "Climb: Exquisite forest floor mountain backdrop"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249514"), attributionText: "CMN Mountain Wildlife",
                gbifData: GBIFData(usageKey: nil, scientificName: "Ursus arctos horribilis", canonicalName: "Grizzly Bear", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Ursidae", genus: "Ursus")
            ),
            DisplayItem(
                id: "mam_4", title: "Cougar",
                shortDescription: "Solitary cat positioned on a steep rocky cliff.",
                detailedDescription: "A solitary mountain lion taxidermy specimen positioned on a steep rocky outcrop, illustrating the ambush tactics of Canada's largest wild feline.",
                funFacts: ["Athletic: Can leap 12 meters horizontally", "Ecology: Peak predator of western ranges", "Paws: Large padded feet for quiet walking"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1534759846116-5799c33ce22a?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249515"), attributionText: "CMN Western Diorama",
                gbifData: GBIFData(usageKey: nil, scientificName: "Puma concolor", canonicalName: "Cougar", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Felidae", genus: "Puma")
            ),
            DisplayItem(
                id: "mam_5", title: "Bull Moose",
                shortDescription: "Massive male moose displaying heavy palmated antlers.",
                detailedDescription: "A massive, full-size male moose featuring a broad, heavy rack of palmated antlers. It serves as a classic symbol of the Canadian Boreal forest.",
                funFacts: ["Moose: Largest member of the deer family", "Antlers: Shed and regrown annually", "Water: Excellent swimmers; can dive for plants"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249516"), attributionText: "CMN Boreal Forest",
                gbifData: GBIFData(usageKey: nil, scientificName: "Alces alces", canonicalName: "Bull Moose", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Cervidae", genus: "Alces")
            ),
            DisplayItem(
                id: "mam_6", title: "Barren-Ground Caribou",
                shortDescription: "Group of northern caribou mid-migration.",
                detailedDescription: "A family herd segment of barren-ground caribou presented mid-migration, set against an wide Arctic tundra background.",
                funFacts: ["Shed: Both males and females grow antlers", "Hooves: Wide, split hooves act like snowshoes", "Migrate: Travel up to 5,000 km annually"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1517783999520-f068d7431a60?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249517"), attributionText: "CMN Arctic Landscape",
                gbifData: GBIFData(usageKey: nil, scientificName: "Rangifer tarandus groenlandicus", canonicalName: "Barren-Ground Caribou", rank: "Subspecies", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Cervidae", genus: "Rangifer")
            ),
            DisplayItem(
                id: "mam_7", title: "Pronghorn Antelope",
                shortDescription: "Lean prairie runners with specialized branched horns.",
                detailedDescription: "Pronghorn mounts configured to display their highly unique skin-sheathed branched horns and lean skeletal builds optimized for high-speed endurance running.",
                funFacts: ["Speed: Fastest land mammal in North America", "Horns: Sheaths shed annually, core is bone", "Vision: Large eyes equivalent to binoculars"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1470240731273-7821a6eeb6bd?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249518"), attributionText: "CMN Grasslands",
                gbifData: GBIFData(usageKey: nil, scientificName: "Antilocapra americana", canonicalName: "Pronghorn", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Antilocapridae", genus: "Antilocapra")
            ),
            DisplayItem(
                id: "mam_8", title: "Mountain Goat",
                shortDescription: "Alpine climber showing specialized traction hooves.",
                detailedDescription: "An alpine mountain goat mount positioned high on simulated steep cliffside ledges to showcase their specialized rubbery traction hooves.",
                funFacts: ["Climb: rubbber-like pads for grip", "Fur: Bright white double coat for wind defense", "Horns: Slender, sharp black horns used to defend territory"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1548676924-48e71ceac151?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249519"), attributionText: "CMN Rocky Peaks",
                gbifData: GBIFData(usageKey: nil, scientificName: "Oreamnos americanus", canonicalName: "Mountain Goat", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Bovidae", genus: "Oreamnos")
            ),
            DisplayItem(
                id: "mam_9", title: "Polar Bear",
                shortDescription: "Iconic white marine apex predator of the Arctic.",
                detailedDescription: "A stark white apex predator mount standing on a sea ice diorama, illustrating hollow heat-absorbing fur and thick insulating fat.",
                funFacts: ["Skin: Black skin beneath white fur", "Hairs: Hollow tubes trap solar heat", "Diet: Highly reliant on ice-edge seals"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1589656966895-2f33e7653819?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249520"), attributionText: "CMN High-Arctic Marine",
                gbifData: GBIFData(usageKey: nil, scientificName: "Ursus maritimus", canonicalName: "Polar Bear", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Ursidae", genus: "Ursus")
            ),
            DisplayItem(
                id: "mam_10", title: "Ringed Seal",
                shortDescription: "Ice-dependent seal displaying key predator-prey links.",
                detailedDescription: "Placed alongside the polar bear diorama to illustrate the critical, interconnected predator-prey dynamics of the high Arctic marine ecosystem.",
                funFacts: ["Behavior: Carves breathing holes through ice", "Status: Primary food source for polar bears", "Nesting: Raises pups in snow caves"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1591115765373-520b709e60c5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249521"), attributionText: "CMN Polar Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Pusa hispida", canonicalName: "Ringed Seal", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Phocidae", genus: "Pusa")
            ),
            DisplayItem(
                id: "mam_11", title: "American Beaver",
                shortDescription: "Prominent rodent shown beside a replica lodge.",
                detailedDescription: "A beautifully constructed lodge display housing this semi-aquatic rodent. Showcases specialized flat balancing tails and chisel teeth.",
                funFacts: ["Ecology: Landscape engineers building wetlands", "Teeth: Orange enamel loaded with iron", "Tail: Flat rudder used for slap warning signaling"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249522"), attributionText: "CMN Wetland Exhibit",
                gbifData: GBIFData(usageKey: nil, scientificName: "Castor canadensis", canonicalName: "American Beaver", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Rodentia", family: "Castoridae", genus: "Castor")
            ),
            DisplayItem(
                id: "mam_12", title: "Canada Lynx",
                shortDescription: "Preserved wildcat showing winter snowshoe paws.",
                detailedDescription: "A beautifully preserved northern cat featuring thick insulating gray-brown fur, a short bobbed tail, and wide, snowshoe-like paws.",
                funFacts: ["Paws: Distributes weight over deep snow", "Diet: Highly synchronized to snowshoe hare populations", "Ear tufts: Function like hearing range extenders"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1629814231649-6e3a0972fe0f?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/3041249523"), attributionText: "CMN Taiga Collection",
                gbifData: GBIFData(usageKey: nil, scientificName: "Lynx canadensis", canonicalName: "Canada Lynx", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Felidae", genus: "Lynx")
            )
        ]
    }
    
    // MARK: - Level 3: Earth Gallery Data (12 Items)
    private func getEarthSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "ear_1", title: "Apollo 17 Moon Rock",
                shortDescription: "A rare lunar rock sample collected during space missions.",
                detailedDescription: "An authentic, three-billion-year-old rock sample returned to Earth during the Apollo 17 lunar mission in 1972. Safely encased in a viewing sphere.",
                funFacts: ["Age: Approximately 3 Billion Years Old", "Source: Taurus-Littrow Valley on the Moon", "Centerpiece of the Earth Gallery"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1545128485-c400e7702796?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245112"), attributionText: "CMN Extraterrestrial / NASA",
                gbifData: GBIFData(usageKey: nil, scientificName: "Lunar Basalt", canonicalName: "Moon Rock", rank: "Lavas", kingdom: "Mineralia", phylum: "Extraterrestrial", taxonomicClass: "Igneous", order: "Basalt", family: "Anorthosite", genus: nil)
            ),
            DisplayItem(
                id: "ear_2", title: "Acasta Gneiss",
                shortDescription: "The oldest known intact crustal rock on earth.",
                detailedDescription: "A specimen representing the absolute oldest intact crustal basement rock formation discovered on Earth, originating from the Northwest Territories.",
                funFacts: ["Age: 4.03 Billion Years Old", "Origin: Slave Province, NWT", "Ecology: Pre-dates multicellular organic life"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1515586000433-45406d4e2d4d?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245113"), attributionText: "CMN National Rock Collection",
                gbifData: GBIFData(usageKey: nil, scientificName: "Acasta Gneiss", canonicalName: "Earth Primitive Crust", rank: "Specimen", kingdom: "Mineralia", phylum: "Metamorphic", taxonomicClass: "Gneiss", order: "Granitolite", family: "Feldspar", genus: nil)
            ),
            DisplayItem(
                id: "ear_3", title: "Petarasite from Mont Saint-Hilaire",
                shortDescription: "A rare citizen-science donation from a global mineral hotspot.",
                detailedDescription: "Mont Saint-Hilaire in Quebec is a renowned geological site where over 440 species have been found. This rare mineral is a prized display piece.",
                funFacts: ["Locality: Mont Saint-Hilaire, Quebec", "Rarity: One of the rarest minerals globally", "Structure: Beautiful monoclinic crystal groups"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245114"), attributionText: "CMN Citizen Donation",
                gbifData: GBIFData(usageKey: nil, scientificName: "Petarasite", canonicalName: "Petarasite", rank: "Species", kingdom: "Mineralia", phylum: "Silicates", taxonomicClass: "Zirconosilicate", order: "Hydrous", family: "Monoclinic", genus: nil)
            ),
            DisplayItem(
                id: "ear_4", title: "Giant Amethyst Geode",
                shortDescription: "Oversized cluster of deep purple quartz crystal points.",
                detailedDescription: "An exceptional, towering geode cavity blanketed in rich purple quartz crystal structures. One of the gallery's most popular visual displays.",
                funFacts: ["Color: Trace iron structures inside silica gates", "Structure: Hexagonal crystal points", "Scale: Weighs over 180 kilograms"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1598212002405-1563205a49a9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245115"), attributionText: "CMN National Gem Vault",
                gbifData: GBIFData(usageKey: nil, scientificName: "Quartz var. Amethyst", canonicalName: "Amethyst Geode", rank: "Variety", kingdom: "Mineralia", phylum: "Oxides", taxonomicClass: "Silica", order: "Trigonal", family: "Quartz", genus: nil)
            ),
            DisplayItem(
                id: "ear_5", title: "Iridescent Ammolite Fossil",
                shortDescription: "71-million-year-old beautifully glowing Albertan shell.",
                detailedDescription: "A stunning, complete fossilized ammonite shell showcasing a shifting spectrum of fiery reds, greens, and yellows.",
                funFacts: ["Age: 71 Million Years Old", "Location: Bearpaw Formation, Alberta", "Structure: Gemstone layer formed from fossil shells"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245116"), attributionText: "CMN Invertebrate Vault",
                gbifData: GBIFData(usageKey: nil, scientificName: "Placenticeras meeki", canonicalName: "Ammolite Ammonite", rank: "Species", kingdom: "Animalia", phylum: "Mollusca", taxonomicClass: "Cephalopoda", order: "Ammonitida", family: "Placenticeratidae", genus: "Placenticeras")
            ),
            DisplayItem(
                id: "ear_6", title: "Sudbury Nickel-Copper Ore",
                shortDescription: "Massive raw geological core sample from the famous mining basin.",
                detailedDescription: "A massive, unrefined ore block loaded with nickel and copper sulfides. Represents the impact event that shaped the mining basin.",
                funFacts: ["Impact: Formed by a massive meteorite strike", "Industry: Foundational to Canadian mining history", "Mineralogy: Heavy chalcopyrite and pentlandite mix"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245117"), attributionText: "CMN Economic Geology",
                gbifData: GBIFData(usageKey: nil, scientificName: "Pentlandite / Chalcopyrite", canonicalName: "Sudbury Ore", rank: "Sulfides", kingdom: "Mineralia", phylum: "Metallic Ores", taxonomicClass: "Sulfide", order: "Heavy Metals", family: "Base Ores", genus: nil)
            ),
            DisplayItem(
                id: "ear_7", title: "Perticara Sulphur Crystals",
                shortDescription: "A striking, bright yellow historic crystal cluster.",
                detailedDescription: "Imported from historic mines in Emilia-Romagna, Italy. Displays near-flawless yellow crystalline structures and deep geometric layouts.",
                funFacts: ["Size: Exceptional 18 x 15 cm display", "Origin: Romagna mining basin, Italy", "Structure: Orthorhombic sulfur crystal structures"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245118"), attributionText: "CMN Mineral Exchange",
                gbifData: GBIFData(usageKey: nil, scientificName: "Native Sulfur", canonicalName: "Perticara Sulphur", rank: "Element", kingdom: "Mineralia", phylum: "Native Elements", taxonomicClass: "Non-Metal", order: "Orthorhombic", family: "Sulfur Group", genus: nil)
            ),
            DisplayItem(
                id: "ear_8", title: "Azurite and Malachite",
                shortDescription: "Vibrant royal blue azurite interwoven with velvety green malachite.",
                detailedDescription: "A beautiful, premium display mineral showcasing deep blue azurite crystals alongside green malachite copper carbonates, representing weathered copper ore deposits.",
                funFacts: ["Contrast: Deep royal blue meets rich green", "Chemistry: Copper carbon minerals", "Artifact: Historic base pigments for ancient paints"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1515586000433-45406d4e2d4d?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245119"), attributionText: "CMN Copper Minerals",
                gbifData: GBIFData(usageKey: nil, scientificName: "Azurite-Malachite complex", canonicalName: "Azurite & Malachite", rank: "Compound", kingdom: "Mineralia", phylum: "Carbonates", taxonomicClass: "Basic Carbonates", order: "Monoclinic", family: "Copper Minerals", genus: nil)
            ),
            DisplayItem(
                id: "ear_9", title: "Uvite Tourmaline",
                shortDescription: "A dense, dark cluster of black tourmaline crystals.",
                detailedDescription: "A prominent aggregate of well-formed black tourmaline crystals that serves as an anchor piece for the structural mineralogy collection.",
                funFacts: ["Structure: Highly complex borosilicate ring structures", "Symmetry: Striking trigonal symmetry", "Use: Excellent piezo-electric demonstration specimen"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245120"), attributionText: "CMN Tourmaline Display",
                gbifData: GBIFData(usageKey: nil, scientificName: "Uvite", canonicalName: "Uvite", rank: "Species", kingdom: "Mineralia", phylum: "Silicates", taxonomicClass: "Cyclosilicate", order: "Tourmaline Group", family: "Borosilicates", genus: nil)
            ),
            DisplayItem(
                id: "ear_10", title: "Bright White Calcite",
                shortDescription: "Geometric, pristine white calcite crystal clusters.",
                detailedDescription: "Perfectly geometric crystals presented under specialized museum spotlighting to highlight their double-refraction crystal faces.",
                funFacts: ["Light: Highly refractive (double refraction)", "Structure: Pure rhombohedral crystal forms", "Locality: Sourced from classic mining regions in Quebec"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245121"), attributionText: "CMN Calcite Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Calcite", canonicalName: "Calcite", rank: "Species", kingdom: "Mineralia", phylum: "Carbonates", taxonomicClass: "Calcium Carbonate", order: "Trigonal", family: "Calcite Group", genus: nil)
            ),
            DisplayItem(
                id: "ear_11", title: "Walk-In Limestone Cave",
                shortDescription: "A life-size replica cave system highlighting dripping stalactites.",
                detailedDescription: "A realistic walk-in cave showcasing replica faux sedimentary walls, dripping water sounds, hidden bats, and realistic stalactites and stalagmites.",
                funFacts: ["Popular highlight for young visitors", "Features: Replicates cave limestone dissolution", "Ecology: Illustrates groundwater flow paths"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245122"), attributionText: "CMN Geology Formations",
                gbifData: GBIFData(usageKey: nil, scientificName: "Limestone cave replica", canonicalName: "Cave Replica", rank: "Structures", kingdom: "Sedimentaria", phylum: "Karst", taxonomicClass: "Speleothems", order: "Erosional", family: "Cave Environments", genus: nil)
            ),
            DisplayItem(
                id: "ear_12", title: "The Ultraviolet Fluorescent Box",
                shortDescription: "Immersive dark chamber showcasing glowing minerals.",
                detailedDescription: "An interactive chamber that floods mineral specimens with UV light, causing them to glow in vibrant neon greens, pinks, and purples.",
                funFacts: ["Cause: Light photons excite atomic core shells", "Exhibit: Interactive button interface", "Colors: Displays glowing fluorite and calcite"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1541185933-ef5d8ed016c2?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/4431245123"), attributionText: "CMN Mineralogy Lab",
                gbifData: GBIFData(usageKey: nil, scientificName: "Fluorescent Minerals", canonicalName: "Glowing Rocks", rank: "Displays", kingdom: "Mineralia", phylum: "Luminescent Ores", taxonomicClass: "Activated Crystals", order: "Spectral", family: "UV Active", genus: nil)
            )
        ]
    }
    
    // MARK: - Level 3: Bird Gallery Data (12 Items)
    private func getBirdSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "bir_1", title: "Passenger Pigeon",
                shortDescription: "Historically significant mount of this extinct Canadian bird.",
                detailedDescription: "A beautifully preserved passenger pigeon specimen. Once numbering in the billions across eastern Canada before being hunted to extinction by 1914.",
                funFacts: ["Extinct: Final wild flock vanished by 1914", "Message: Highlights the impact of overhunting", "Exhibit: Centerpiece of bird gallery archives"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1452570053594-1b985d6ea890?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124112"), attributionText: "CMN Extinct Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Ectopistes migratorius", canonicalName: "Passenger Pigeon", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Columbiformes", family: "Columbidae", genus: "Ectopistes")
            ),
            DisplayItem(
                id: "bir_2", title: "Eskimo Curlew",
                shortDescription: "Critically endangered and possibly extinct shorebird.",
                detailedDescription: "A prized, delicate shorebird mount serving as a solemn reminder of human impacts on North American migratory flyways.",
                funFacts: ["Rarity: Extremely rare mount on display", "Status: Critically endangered (possibly extinct)", "Migration: Traveled from Arctic tundra to South America"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1484557052118-f32bd25b45b5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124113"), attributionText: "CMN Endangered Vault",
                gbifData: GBIFData(usageKey: nil, scientificName: "Numenius borealis", canonicalName: "Eskimo Curlew", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Charadriiformes", family: "Scolopacidae", genus: "Numenius")
            ),
            DisplayItem(
                id: "bir_3", title: "Whooping Crane",
                shortDescription: "Strikingly tall specimen of one of Canada's rarest birds.",
                detailedDescription: "A tall marshland crane demonstrating the results of successful international wetland habitat protection plans.",
                funFacts: ["Height: Tallest bird species in North America", "Population: Recovering from fewer than 25 wild individuals", "Call: Loud, bugle-like vocalizations"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124114"), attributionText: "CMN Ornithological Records",
                gbifData: GBIFData(usageKey: nil, scientificName: "Grus americana", canonicalName: "Whooping Crane", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Gruiformes", family: "Gruidae", genus: "Grus")
            ),
            DisplayItem(
                id: "bir_4", title: "Bald Eagle",
                shortDescription: "Apex raptor presented up close in flight.",
                detailedDescription: "A full-sized apex raptor taxidermy mount showing a powerful curved hunting beak and sharp, heavy fish-snatching talons.",
                funFacts: ["Talons: Exerts over 400 psi of crushing force", "Wingspan: Up to 2.3 meters (7.5 ft.)", "Nests: Builds massive stick nests weighting up to a tonne"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1611689342806-0863700ce1e4?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124115"), attributionText: "CMN Raptor Hall",
                gbifData: GBIFData(usageKey: nil, scientificName: "Haliaeetus leucocephalus", canonicalName: "Bald Eagle", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Accipitriformes", family: "Accipitridae", genus: "Haliaeetus")
            ),
            DisplayItem(
                id: "bir_5", title: "Osprey",
                shortDescription: "Positioned mid-air in a dramatic diving hunting pose.",
                detailedDescription: "Mounted in a dynamic dive-bombing posture, illustrating its unique, rough pads on its feet adapted for catching slippery fish.",
                funFacts: ["Reversible Toe: Can hold fish head-first for aerodynamic flight", "Vision: Detects fish underwater from 40 meters up", "Diet: 99% of prey is freshwater or marine fish"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1533158326339-7f3cf2404354?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124116"), attributionText: "CMN Piscivore Displays",
                gbifData: GBIFData(usageKey: nil, scientificName: "Pandion haliaetus", canonicalName: "Osprey", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Accipitriformes", family: "Pandionidae", genus: "Pandion")
            ),
            DisplayItem(
                id: "bir_6", title: "Great Horned Owl",
                shortDescription: "Nocturnal hunter featuring a highly sensitive facial feather disc.",
                detailedDescription: "A nocturnal predator showing specialized forward-facing facial feather discs designed to funnel sound directly into its offset ears.",
                funFacts: ["Hearing: Pinpoints prey beneath leaf litter in total dark", "Sleeves: Soft wing fringes allow silent flight", "Eyes: Static tubular eyes; must turn head 270 degrees"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1543549790-8b5f4a028cfb?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124117"), attributionText: "CMN Nocturnal Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Bubo virginianus", canonicalName: "Great Horned Owl", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Strigiformes", family: "Strigidae", genus: "Bubo")
            ),
            DisplayItem(
                id: "bir_7", title: "Snowy Owl",
                shortDescription: "Stark white Arctic specialist with heavily feathered feet.",
                detailedDescription: "An iconic white owl mount showcasing insulating feathers extending to its toes to withstand freezing tundra winds.",
                funFacts: ["Feet: Thickly feathered toes act like snow boots", "Hunting: Active hunting during arctic summer days", "Color: Mature wishes are almost pure white for camouflage"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124118"), attributionText: "CMN Arctic Exhibit",
                gbifData: GBIFData(usageKey: nil, scientificName: "Bubo scandiacus", canonicalName: "Snowy Owl", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Strigiformes", family: "Strigidae", genus: "Bubo")
            ),
            DisplayItem(
                id: "bir_8", title: "Common Loon",
                shortDescription: "Iconic Canadian water bird showing solid skeletal bones.",
                detailedDescription: "An exceptional mount demonstrating how loons' solid bones help them dive deep into lakes, alongside its strikingly patterned plumage.",
                funFacts: ["Solid Bones: Heavy bones act like weights for deep dives", "Position: Legs set far back, making walking on land difficult", "Voice: Famous haunting calls heard across Canada"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124119"), attributionText: "CMN Boreal Lake",
                gbifData: GBIFData(usageKey: nil, scientificName: "Gavia immer", canonicalName: "Common Loon", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Gaviiformes", family: "Gaviidae", genus: "Gavia")
            ),
            DisplayItem(
                id: "bir_9", title: "Harlequin Duck",
                shortDescription: "Vividly patterned sea duck built for churning surf.",
                detailedDescription: "A beautifully patterned river duck designed with dense bones and insulating down, allowing it to dive in turbulent coastal surf.",
                funFacts: ["Surf: Feeds in turbulent, highly oxygenated rapids", "Color: Stunning slate-blue and white markings", "Diet: Small crabs and roe from gravel beds"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124120"), attributionText: "CMN Coastal Surf",
                gbifData: GBIFData(usageKey: nil, scientificName: "Histrionicus histrionicus", canonicalName: "Harlequin Duck", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Anseriformes", family: "Anatidae", genus: "Histrionicus")
            ),
            DisplayItem(
                id: "bir_10", title: "Rock Ptarmigan",
                shortDescription: "Insulating grouse illustrating seasonal winter camouflage.",
                detailedDescription: "A specimen showing seasonal plumage shifts, molting from direct gravel-patterned browns to solid white for snow camouflage.",
                funFacts: ["Camouflage: Shifting colors match winter snowpacks", "Warmth: Feathery nostrils trap warm breath", "Habitat: High altitude rocky tundra plains"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1517783999520-f068d7431a60?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124121"), attributionText: "CMN Alpine Tundra",
                gbifData: GBIFData(usageKey: nil, scientificName: "Lagopus muta", canonicalName: "Rock Ptarmigan", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Galliformes", family: "Phasianidae", genus: "Lagopus")
            ),
            DisplayItem(
                id: "bir_11", title: "The 1925 Bird's Nest",
                shortDescription: "Century-old basket nest demonstrating delicate weaving.",
                detailedDescription: "A perfectly preserved nest specimen from 1925, showcasing the intricate building skills of small songbirds.",
                funFacts: ["Age: Hand-woven over 100 years ago", "Material: Dried grasses, lichens, and spiderwebs", "Insulation: Fine down lining preserves clutch temps"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124122"), attributionText: "CMN Historical Nest",
                gbifData: GBIFData(usageKey: nil, scientificName: "Passeriformes nid.", canonicalName: "Woven Songbird Nest", rank: "Order", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Passeriformes", family: nil, genus: nil)
            ),
            DisplayItem(
                id: "bir_12", title: "Magnificent Bird-of-Paradise",
                shortDescription: "Iridescent exotic specimen prepared in 1957.",
                detailedDescription: "An exotic specimen collected during a 1957 expedition. Prepared without feet following the traditional customs of indigenous New Guinea hunters.",
                funFacts: ["Rarity: Displayed to highlight global diversity", "Gold fan cape feathers used in mating dances", "Footless Prep: Traditional taxidermy style from New Guinea"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1452570053594-1b985d6ea890?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/1215124123"), attributionText: "CMN Global Avian Registry",
                gbifData: GBIFData(usageKey: nil, scientificName: "Diphyllodes magnificus", canonicalName: "Magnificent Bird-of-Paradise", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Aves", order: "Passeriformes", family: "Paradisaeidae", genus: "Diphyllodes")
            )
        ]
    }
    
    // MARK: - Level 4: Canada Goose Arctic Data (12 Items)
    private func getArcticSpecs() -> [DisplayItem] {
        return [
            DisplayItem(
                id: "arc_1", title: "'Beyond Ice' Sculpture",
                shortDescription: "Interactive blockbuster ice block installation.",
                detailedDescription: "A massive, interactive central installation of real ice. Visitors can touch the freezing block and leave heat handprints on its icy shell.",
                funFacts: ["Touch: Interactive real ice cooling block", "Message: Focuses on warming ice sheets", "Visual: Embedded with blue accent lights"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1481819613668-ac109b4db879?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441231"), attributionText: "CMN Arctic Main Gallery",
                gbifData: GBIFData(usageKey: nil, scientificName: "Glacial Ice", canonicalName: "Interactive Ice Sculpture", rank: "Display", kingdom: "Abiotic", phylum: "Melted", taxonomicClass: "Glacial", order: "Solid Water", family: "Crystalline", genus: nil)
            ),
            DisplayItem(
                id: "arc_2", title: "Aurora Light Chamber",
                shortDescription: "Atmospheric projection mapping of northern lights.",
                detailedDescription: "A designed media space that projects high-fidelity atmospheric simulations of shifting northern lights across the exhibition walls.",
                funFacts: ["Immersive: 360-degree digital projection mapping", "Audio: Features cool, real northern wind sounds", "Education: Explains planetary magnetic fields"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1541185933-ef5d8ed016c2?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441232"), attributionText: "CMN Multimedia Gallery",
                gbifData: GBIFData(usageKey: nil, scientificName: "Aurora Borealis Chamber", canonicalName: "Northern Lights Room", rank: "Chamber", kingdom: "Abiotic", phylum: "Light", taxonomicClass: "Magnetic", order: "Solar wind", family: "Excited Ions", genus: nil)
            ),
            DisplayItem(
                id: "arc_3", title: "Adult Polar Bear",
                shortDescription: "Premier full-size apex predator mount of the Arctic.",
                detailedDescription: "A beautiful, full-size male polar bear mount highlighting the thick, hollow fur and dense fat layers required for sea ice survival.",
                funFacts: ["Fur: Dense, protective hollow coat", "Size: Standing tall at nearly 3 meters", "Predatory: Peak hunter of marine ice lines"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1589656966895-2f33e7653819?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441233"), attributionText: "CMN Polar Bear Exhibit",
                gbifData: GBIFData(usageKey: nil, scientificName: "Ursus maritimus", canonicalName: "Polar Bear", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Carnivora", family: "Ursidae", genus: "Ursus")
            ),
            DisplayItem(
                id: "arc_4", title: "Barren-Ground Caribou",
                shortDescription: "Insulating northern caribou, using wide split-hooves.",
                detailedDescription: "A majestic caribou specimen displaying wide, split hooves that act like snowshoes across deep winter snow drifts.",
                funFacts: ["Hooves: Scoop-like hooves used to dig for lichens", "Fur: Hollow fur traps body heat", "Migration: Travels across vast Arctic valleys"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441234"), attributionText: "CMN Arctic herding displays",
                gbifData: GBIFData(usageKey: nil, scientificName: "Rangifer tarandus", canonicalName: "Arctic Caribou", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Cervidae", genus: "Rangifer")
            ),
            DisplayItem(
                id: "arc_5", title: "Muskox and Calf",
                shortDescription: "Heavily insulated Arctic family pairing group.",
                detailedDescription: "A rare family pairing displaying their signature dense, skirt-like underfur (qiviut) and sharp, curved defensive horns.",
                funFacts: ["qiviut underfur: 8x warmer than sheep wool", "Horn: Merged horn boss across forehead", "Defense: Forms an outward-facing protective wall"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1548676924-48e71ceac151?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441235"), attributionText: "CMN Arctic Lands",
                gbifData: GBIFData(usageKey: nil, scientificName: "Ovibos moschatus", canonicalName: "Muskox", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Artiodactyla", family: "Bovidae", genus: "Ovibos")
            ),
            DisplayItem(
                id: "arc_6", title: "Bowhead Whale Skull",
                shortDescription: "Genuine skeletal skull used to break thin ice.",
                detailedDescription: "A giant, authentic Bowhead whale skull demonstrating how these mammals use their heads to break through Arctic sea ice from below.",
                funFacts: ["Bone: Incredibly thick cranial skull boss", "Ice: Can break ice up to 60 cm thick", "Baleen: Long plates filter millions of krill"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441236"), attributionText: "CMN National Marine Skull",
                gbifData: GBIFData(usageKey: nil, scientificName: "Balaena mysticetus", canonicalName: "Bowhead Whale", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Cetacea", family: "Balaenidae", genus: "Balaena")
            ),
            DisplayItem(
                id: "arc_7", title: "Life-Sized Narwhal Model",
                shortDescription: "Detailed overhead model showing the spiral-grooved tusk.",
                detailedDescription: "An impressive, suspended overhead model displaying the spiral-grooved tusk, which is actually an elongated front tooth.",
                funFacts: ["Tusk: Left front tooth grows up to 3 meters", "Sensory: Tooth contains millions of nerve endings", "Legend: Inspired early European unicorn myths"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1533158326339-7f3cf2404354?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441237"), attributionText: "CMN Model Archives",
                gbifData: GBIFData(usageKey: nil, scientificName: "Monodon monoceros", canonicalName: "Narwhal", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Cetacea", family: "Monodontidae", genus: "Monodon")
            ),
            DisplayItem(
                id: "arc_8", title: "Life-Sized Beluga Model",
                shortDescription: "Suspended replica of the social 'sea canary'.",
                detailedDescription: "A realistic canopy model of this highly vocal whale, displaying its lack of a dorsal fin, which allows it to swim easily beneath ice sheets.",
                funFacts: ["Dorsal Fin: Lacks fin to avoid scraping ice", "Melon: Bulbous forehead shapes sonar calls", "Vocal: Dubbed the 'sea canary' for its chirps"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441238"), attributionText: "CMN Cetacean Mock Archive",
                gbifData: GBIFData(usageKey: nil, scientificName: "Delphinapterus leucas", canonicalName: "Beluga Whale", rank: "Species", kingdom: "Animalia", phylum: "Chordata", taxonomicClass: "Mammalia", order: "Cetacea", family: "Monodontidae", genus: "Delphinapterus")
            ),
            DisplayItem(
                id: "arc_10", title: "Inuit Beluga Smokehouse Model",
                shortDescription: "Scaled model of traditional whale meat preservation.",
                detailedDescription: "A historically accurate architectural model displaying traditional methods used by northern communities to air-dry and preserve whale meat.",
                funFacts: ["Culture: Replicates traditional coastal camp setups", "Scale: Hand-carved pine and leather model", "Ecology: Shows deep relationships with whale migrations"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441240"), attributionText: "CMN Cultural Heritage",
                gbifData: GBIFData(usageKey: nil, scientificName: "Beluga Smokehouse replica", canonicalName: "Curing Smokehouse Model", rank: "Architecture", kingdom: "Historical", phylum: "Wood", taxonomicClass: "Scaled Model", order: "Northern Living", family: "Inuit Culture", genus: nil)
            ),
            DisplayItem(
                id: "arc_9", title: "Franklin Expedition Relics",
                shortDescription: "Authentic recovery objects from Sir John Franklin's voyage.",
                detailedDescription: "Preserved relics from an 1840s encampment of sailors from Sir John Franklin's lost Arctic voyage, including metal buttons, a nail, and a clay pipe.",
                funFacts: ["Historic: Sourced from Beechey Island encampments", "Rarity: Direct links to the 1845 Franklin voyage", "Ecology: Illustrates early Arctic navigation risks"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1452570053594-1b985d6ea890?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441239"), attributionText: "CMN Polar Exploration",
                gbifData: GBIFData(usageKey: nil, scientificName: "Franklin Relics", canonicalName: "HMS Erebus Artifacts", rank: "Objects", kingdom: "Historical", phylum: "Metal", taxonomicClass: "Sinking-debris", order: "Franklin Voyage", family: "Lost Crews", genus: nil)
            ),
            DisplayItem(
                id: "arc_11", title: "Inuit Tools and Carvings",
                shortDescription: "Traditional carvings in the Northern Voices gallery.",
                detailedDescription: "A rotating, curated collection of carvings and bone tools, illustrating deep relationships with local northern wildlife.",
                funFacts: ["Location: Curated in the Northern Voices Gallery", "Material: Carved from soapstone and antler bone", "Artistry: Depicts native polar animals"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441241"), attributionText: "CMN Northern Voices",
                gbifData: GBIFData(usageKey: nil, scientificName: "Inuit Carving Collection", canonicalName: "Northern Voices Carvings", rank: "Art", kingdom: "Historical", phylum: "Stone", taxonomicClass: "Ethno-artworks", order: "Contemporary soapstone", family: "Inuit Heritage", genus: nil)
            ),
            DisplayItem(
                id: "arc_12", title: "Preserved Arctic Flora Sheets",
                shortDescription: "Vetted botanical sheets of tiny tundra plants.",
                detailedDescription: "Select botanical sheets (such as dwarf birch and Arctic poppy), demonstrating how miniature plants survive high winds and permafrost.",
                funFacts: ["Size: Miniature plants hug the ground for warmth", "Resilient: Survives in frozen permafrost soils", "Display: Part of the museum's National Herbarium"],
                imageUrl: URL(string: "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&q=80&w=800"),
                sourceUrl: URL(string: "https://www.gbif.org/occurrence/6123441242"), attributionText: "CMN National Herbarium",
                gbifData: GBIFData(usageKey: nil, scientificName: "Papaver radicatum", canonicalName: "Arctic Poppy", rank: "Species", kingdom: "Plantae", phylum: "Tracheophyta", taxonomicClass: "Magnoliopsida", order: "Ranunculales", family: "Papaveraceae", genus: "Papaver")
            )
        ]
    }
}
