//
//  SpecimenImageCatalogue.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Curated, deterministic image URL registry for known museum specimen IDs.
///
/// This is used as the primary image source for curated records to ensure
/// stable visuals and predictable loading behavior.
enum SpecimenImageCatalogue {
    /// Returns a curated image URL for a known specimen ID, if available.
    /// - Parameter id: Curated specimen ID (e.g., `bug_1`, `fos_3`, `arc_8`).
    /// - Returns: URL for that specimen's curated image, or `nil` if unmapped.
    static func url(for id: String) -> URL? {
        let urlPath: String

        switch id {
        // --- LEVEL 0: BUGS ALIVE GALLERY ---
        case "bug_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/4/41/Leafcutter_ants_behavior.jpg"
        case "bug_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/73/Grammostola_rosea_m_1.JPG"
        case "bug_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/f9/Lasiodora_parahybana_2.jpg"
        case "bug_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/0/05/Madagascar_Hissing_Cockroach_Gromphadorhina_portentosa.jpg"
        case "bug_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/e/e0/Heterometrus_spinifer_scorp.jpg"
        case "bug_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/de/Psytalla_horrida_01.jpg"
        case "bug_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/fe/Heteropteryx_dilatata_01.jpg"
        case "bug_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/dd/Eurycantha_calcarata_01.jpg"
        case "bug_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/7d/Pseudophyllus_titan.jpg"
        case "bug_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/87/Asbolus_verrucosus.jpg"
        case "bug_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/3/36/Dynastes_hercules_hercules_male_Oli.jpg"
        case "bug_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/3/31/Chrysolina_fastuosa_weevil.jpg"

        // --- LEVEL 1: FOSSIL GALLERY ---
        case "fos_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/7f/Daspletosaurus_torosus_skull.jpg"
        case "fos_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Edmontosaurus_Anatosaurus_mummy_fossil.jpg"
        case "fos_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Triceratops_prorsus_skull_AMNH_5116.jpg"
        case "fos_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/dd/Styracosaurus_albertensis_Sternberg_1915.jpg"
        case "fos_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/d4/Chasmosaurus_belli_skull.jpg"
        case "fos_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/74/Spiclypeus_shipporum_holotype.jpg"
        case "fos_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/5a/Elasmosaurus_platyurus_cmn.jpg"
        case "fos_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/52/Platecarpus_coryphaeus_fossil.jpg"
        case "fos_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/ff/Champsosaurus_skeleton.jpg"
        case "fos_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/db/Tiktaalik_roseae_model.jpg"
        case "fos_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/7a/Camelops_fossil_cranial.jpg"
        case "fos_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/69/Mammuthus_primigenius_cranial_tusk.jpg"

        // --- LEVEL 2: WATER GALLERY ---
        case "wat_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/e/ea/Blue_whale_skeleton_Canadian_Museum_of_Nature.jpg"
        case "wat_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/2/21/Aurelia_aurita_2.jpg"
        case "wat_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Pisaster_ochraceus_on_rocks.jpg"
        case "wat_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Strongylocentrotus_droebachiensis.jpg"
        case "wat_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/9/9f/Parastichopus_californicus_underwater.jpg"
        case "wat_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/2/26/Metridium_farcimen_plumose.jpg"
        case "wat_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/4/4c/Clemmys_guttata_spotted_turtle.jpg"
        case "wat_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/af/Esox_lucius_aquarium.jpg"
        case "wat_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/0/02/Sea_otter_cropped.jpg"
        case "wat_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6b/Metacarcinus_magister_dungeness.jpg"
        case "wat_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/52/Mytilus_edulis_blue_mussel.jpg"
        case "wat_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/ff/Larus_argentatus_herring_gull.jpg"

        // --- LEVEL 2: MAMMAL GALLERY ---
        case "mam_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/8d/American_bison_kansas.jpg"
        case "mam_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/5a/Canis_lupus_standing.jpg"
        case "mam_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/a4/Ursus_arctos_horribilis_grizzly.jpg"
        case "mam_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/d6/Mountain_Lion_Puma_concolor.jpg"
        case "mam_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/8c/Alces_alces_bull_moose.jpg"
        case "mam_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/0/07/Rangifer_tarandus_caribou.jpg"
        case "mam_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/3/30/Antilocapra_americana_pronghorn.jpg"
        case "mam_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/1/10/Oreamnos_americanus_mountain_goat.jpg"
        case "mam_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/4/40/Ursus_maritimus_polar_bear.jpg"
        case "mam_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/85/Pusa_hispida_ringed_seal.jpg"
        case "mam_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6b/American_Beaver.jpg"
        case "mam_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/c/c5/Lynx_canadensis_lynx.jpg"

        // --- LEVEL 3: EARTH GALLERY ---
        case "ear_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/da/Apollo_17_lunar_basalt_70017.jpg"
        case "ear_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/9/9a/Acasta_Gneiss_slab.jpg"
        case "ear_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Petarasite_Mont_Saint_Hilaire.jpg"
        case "ear_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/e/e3/Amethyst_geode_mineral_vault.jpg"
        case "ear_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/c/ca/Placenticeras_meeki_ammolite.jpg"
        case "ear_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/a2/Sudbury_ore_complex_slab.jpg"
        case "ear_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/3/3c/Native_Sulfur_Perticara.jpg"
        case "ear_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/b/b3/Azurite-Malachite_complex.jpg"
        case "ear_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Uvite_tourmaline_mineral.jpg"
        case "ear_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/f2/Calcite_rhombohedral_crystals.jpg"
        case "ear_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/af/Limestone_cavern_stalactites.jpg"
        case "ear_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/9/9a/Fluorescent_minerals_uv_box.jpg"

        // --- LEVEL 3: BIRD GALLERY ---
        case "bir_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/0/07/Ectopistes_migratorius_mount.jpg"
        case "bir_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/1/15/Numenius_borealis_eskimo_curlew.jpg"
        case "bir_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/2/25/Grus_americana_crane.jpg"
        case "bir_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/1/1a/Haliaeetus_leucocephalus_head.jpg"
        case "bir_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/df/Pandion_haliaetus_osprey_in_flight.jpg"
        case "bir_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/3/39/Bubo_virginianus_owl.jpg"
        case "bir_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/2/2c/Bubo_scandiacus_snowy_owl.jpg"
        case "bir_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/f3/Gavia_immer_common_loon.jpg"
        case "bir_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/db/Histrionicus_histrionicus_harlequin.jpg"
        case "bir_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/a/ad/Lagopus_muta_ptarmigan.jpg"
        case "bir_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/d/df/Woven_songbird_nest_1925.jpg"
        case "bir_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/5d/Magnificent_Bird_of_Paradise_plume.jpg"

        // --- LEVEL 4: CANADA GOOSE ARCTIC ---
        case "arc_1": urlPath = "https://upload.wikimedia.org/wikipedia/commons/2/2a/Glacial_ice_iceberg_shelf.jpg"
        case "arc_2": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/5a/Aurora_Borealis_Northern_Lights_Greenland.jpg"
        case "arc_3": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/66/Polar_Bear_Ursus_maritimus_cropped.jpg"
        case "arc_4": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/87/Barren_ground_caribou_rangifer.jpg"
        case "arc_5": urlPath = "https://upload.wikimedia.org/wikipedia/commons/5/5e/Muskox_Ovibos_moschatus_calf.jpg"
        case "arc_6": urlPath = "https://upload.wikimedia.org/wikipedia/commons/4/4e/Bowhead_whale_cranium_bone.jpg"
        case "arc_7": urlPath = "https://upload.wikimedia.org/wikipedia/commons/f/fd/Monodon_monoceros_narwhal_model.jpg"
        case "arc_8": urlPath = "https://upload.wikimedia.org/wikipedia/commons/8/85/Delphinapterus_leucas_beluga.jpg"
        case "arc_9": urlPath = "https://upload.wikimedia.org/wikipedia/commons/c/c9/Franklin_Expedition_relics_hms_erebus.jpg"
        case "arc_10": urlPath = "https://upload.wikimedia.org/wikipedia/commons/9/9d/Inuit_Beluga_Smokehouse_architectural_model.jpg"
        case "arc_11": urlPath = "https://upload.wikimedia.org/wikipedia/commons/7/7c/Inuit_soapstone_carving_display.jpg"
        case "arc_12": urlPath = "https://upload.wikimedia.org/wikipedia/commons/6/6f/Papaver_radicatum_arctic_poppy.jpg"

        default:
            return nil
        }

        return URL(string: urlPath)
    }
}
