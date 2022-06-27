## closset-kopp_2018
dataset_id <- "closset-kopp_2018"



ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

ddata[, c(1, 3:7, 9:10, 12, 14, 16) := NULL]
ddata <- ddata[-(1:9)]
data.table::setnames(ddata, c("species", "reserve_luvisols", "managed_luvisols", "managed_cambisols", "managed_podzols", "managed_gleysols"))


# Recoding colored Excel cells into data
data.table::setkey(ddata, species)
## reserve_luvisols
ddata[c("Athyrium filix-femina", "Dryopteris dilatata", "Agrostis canina", "Calamagrostis epigejos", "Dactylis glomerata", "Holcus mollis", "Poa nemoralis", "Luzula forsteri", "Carex pilulifera", "Carex remota", "Carex sylvatica", "Rubus idaeus", "Veronica officinalis", "Anemone nemorosa", "Ajuga reptans", "Alliaria petiolata", "Galeopsis tetrahit", "Lapsana communis", "Mycelis muralis", "Galium odoratum", "Oxalis acetosella", "Teucrium scorodonia", "Veronica montana", "Viola reichenbachiana", "Viola rivianiana", "Acer platanoides", "Castanea sativa", "Clematis vitalba", "Cytisus scoparius", "Fraxinus excelsior", "Prunus avium", "Sorbus aucuparia", "Tilia cordata", "Lonicera periclymenum"), reserve_luvisols := "2015"]

ddata[c("Cynoglossum germanicum", "Mercurialis perennis", "Moehringia trinervia", "Populus tremula", "Sorbus torminalis"), reserve_luvisols := "1970"]

## managed_luvisols
ddata[c("Dryopteris carthusiana", "Polystichum aculeatum", "Agrostis stolonifera", "Arrhenatherum elatius", "Elymus caninus", "Holcus lanatus", "Poa trivialis", "Carex digitata", "Carex pendula", "Carex pilulifera", "Carex remota", "Chaerophylum temulum", "Chelidonium majus", "Daucus carota", "Epilobium hirsutum", "Fallopia convolvulus", "Hypericum hirsutum", "Solanum dulcamara", "Taraxacum sp.", "Conopodium majus", "Euphorbia cyparissias", "Gallium mollugo", "Hypericum tetrapterum", "Lysimachia vulgaris", "Origanum vulgare", "Veronica chamaedrys", "Adoxa moschatellina", "Allium ursinum", "Paris quadrifolia", "Ranunculus ficaria", "Cardamine flexuosa", "Epilobium montanum", "Lapsana communis", "Veronica hederifolia", "Epipactis helleborine", "Helleborus foetidus", "Neottia nidus avis", "Teucrium scorodonia", "Viola reichenbachiana", "Acer campestre", "Acer pseudoplatanus", "Betula pendula", "Carpinus betulus", "Cornus mas", "Cornus sanguinea", "Crataegus monogyna", "Cytisus scoparius", "Euonymus europaeus", "Fraxinus excelsior", "Ilex aquifolium", "Malus sylvestris", "Mespilus germanica", "Populus tremula", "Prunus avium", "Prunus serotina", "Prunus spinosa", "Quercus petraea", "Quercus robur", "Rosa arvensis", "Sambucus nigra", "Sorbus aucuparia", "Taxus baccata", "Tilia cordata", "Ulmus glabra", "Viburnum lantana", "Hedera helix"), managed_luvisols := "2015"]

ddata[c("Agrostis canina", "Brachypodium pinnatum", "Bromus ramosus", "Poa pratensis", "Carex caryophyllea", "Carex digitata", "Lathyrus montanus", "Vincetoxicum hirundinaria", "Campanula trachelium", "Lysimachia nummularia", "Tilia platyphyllos"), managed_luvisols := "1970"]

## managed_cambisols
ddata[c("Dryopteris dilatata", "Agrostis capillaris", "Agrostis stolonifera", "Calamagrostis epigejos", "Dactylis glomerata", "Deschampsia cespitosa", "Festuca gigantea", "Holcus mollis", "Poa trivialis", "Juncus conglomeratus", "Juncus effusus", "Luzula forsteri", "Luzula multiflora", "Carex digitata", "Carex pendula", "Carex pilulifera", "Carex remota", "Atropa belladonna", "Cardamine impatiens", "Chaerophylum temulum", "Chelidonium majus", "Cynoglossum germanicum", "Hypericum hirsutum", "Ranunculus repens", "Solanum dulcamara", "Taraxacum sp.", "Aquilegia vulgaris", "Euphorbia cyparissias", "Linaria repens", "Lysimachia vulgaris", "Vicia sepium", "Allium ursinum", "Anemone nemorosa", "Arum maculatum", "Hyacinthoides non-scripta", "Paris quadrifolia", "Polygonatum multiflorum", "Ranunculus ficaria", "Alliaria petiolata", "Galeopsis tetrahit", "Geranium robertanium", "Lapsana communis", "Lysimachia nemorum", "Primula elatior", "Rumex sanguineus", "Stachys sylvatica", "Viola odorata", "Epipactis helleborine", "Hypericum montanum", "Impatiens noli tangere", "Neottia nidus avis", "Potentilla sterilis", "Viola reichenbachiana", "Acer platanoides", "Castanea sativa", "Clematis vitalba", "Cornus mas", "Corylus avellana", "Crataegus monogyna", "Cytisus scoparius", "Euonymus europaeus", "Malus sylvestris", "Prunus padus", "Prunus serotina", "Prunus spinosa", "Ribes rubrum", "Rives uva crispa", "Rosa arvensis", "Rosa canina", "Sambucus nigra", "Sorbus aucuparia", "Taxus baccata", "Tilia cordata", "Lonicera periclymenum"), managed_cambisols := "2015"]

ddata[c("Dryopteris x tavelii", "Polystichum setiferum", "Brachypodium pinnatum", "Holcus lanatus", "Poa pratensis", "Cerastium fontanum", "Hypericum perforatum", "Epilobium montanum"), managed_cambisols := "1970"]

## managed_podzols
ddata[c("Athyrium filix-femina", "Dryopteris filix-mas", "Agrostis capillaris", "Agrostis stolonifera", "Dactylis glomerata", "Danthonia decumbens", "Festuca gigantea", "Holcus lanatus", "Poa trivialis", "Juncus conglomeratus", "Juncus effusus", "Juncus tenuis", "Luzula multiflora", "Carex digitata", "Carex pendula", "Carex remota", "Carex sylvatica", "Fallopia convolvulus", "Polygonum hydropiper", "Rubus idaeus", "Digitalis purpurea", "Rumex acetosella", "Vincetoxicum hirundinaria", "Anemone nemorosa", "Hyacinthoides non-scripta", "Polygonatum multiflorum", "Ajuga reptans", "Alliaria petiolata", "Circaea lutetiana", "Galeopsis tetrahit", "Geranium robertanium", "Geum urbanum", "Lapsana communis", "Mercurialis perennis", "Moehringia trinervia", "Mycelis muralis", "Scrophularia nodosa", "Urtica dioica", "Euphorbia amygdaloides", "Lamium galeobdolon", "Oxalis acetosella", "Ruscus aculeatus", "Stellaria holostea", "Veronica montana", "Acer campestre", "Acer platanoides", "Acer pseudoplatanus", "Betula pendula", "Clematis vitalba", "Crataegus monogyna", "Frangula alnus", "Fraxinus excelsior", "Ilex aquifolium", "Picea abies", "Pinus sylvestris", "Prunus avium", "Prunus serotina", "Sorbus aucuparia", "Tilia cordata", "Lonicera periclymenum"), managed_podzols := "2015"]

ddata[c("Festuca ovina", "Luzula campestris", "Carex arenaria", "Carex caryophyllea", "Epilobium angustifolium", "Campanula rotundifolia", "Veronica officinalis", "Hieracium lachenalii", "Corylus avellana", "Hieracium sp."), managed_podzols := "1970"]

## managed_gleysols
ddata[c("Asplenium scolopendrium", "Dryopteris carthusiana", "Dryopteris dilatata", "Bromus ramosus", "Dactylis glomerata", "Festuca heterophylla", "Glyceria declinata", "Melica uniflora", "Phalaris arundinacea", "Juncus inflexus", "Carex remota", "Carex riparia", "Cynoglossum germanicum", "Scrophularia aquatica", "Taraxacum sp.", "Caltha palustris", "Cardamine amara", "Colchicum autumnale", "Dactylorhiza fuchsii", "Dactylorhiza maculata", "Equisetum arvense", "Equisetum telmateia", "Galium palustre", "Vicia sepium", "Adoxa moschatellina", "Allium ursinum", "Anemone nemorosa", "Paris quadrifolia", "Polygonatum multiflorum", "Ranunculus auricomus", "Ranunculus ficaria", "Alliaria petiolata", "Cardamine flexuosa", "Fragaria vesca", "Galeopsis tetrahit", "Geum urbanum", "Lapsana communis", "Listera ovata", "Lysimachia nemorum", "Moehringia trinervia", "Scrophularia nodosa", "Convallaria majalis", "Epipactis helleborine", "Oxalis acetosella", "Potentilla sterilis", "Teucrium scorodonia", "Veronica montana", "Viola reichenbachiana", "Viola rivianiana", "Acer campestre", "Acer platanoides", "Carpinus betulus", "Ilex aquifolium", "Prunus avium", "Prunus padus", "Prunus serotina", "Ribes nigrum", "Ribes rubrum", "Rives uva crispa", "Rosa arvensis", "Sorbus aucuparia", "Lonicera periclymenum"), managed_gleysols := "2015"]

ddata[c("Calamagrostis canescens", "Cirsium arvense", "Cirsium oleraceum", "Lycopus europaeus", "Cirsium palustre", "Hypericum tetrapterum", "Myosotis scorpioides", "Crataegus laevigata", "Frangula alnus", "Salix alba", "Sambucus ebulus", "Equisetum hyemale"), managed_gleysols := "1970"]

# Melting sites
ddata <- data.table::melt(ddata,
  id.vars = "species",
  variable.name = "local",
  value.name = "year"
)

# Recoding, splitting and melting year
ddata[year %in% c("IND", "x"), year := "1970+2015"]
ddata[, c("tmp1", "tmp2") := data.table::tstrsplit(year, "\\+")]
ddata <- data.table::melt(ddata,
  id.vars = c("species", "local"),
  measure.vars = c("tmp1", "tmp2"),
  value.name = "year"
)

ddata <- ddata[!is.na(species) & !is.na(year)]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Compiegne Forest",

  metric = "pa",
  value = 1L,
  unit = "pa",

  variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  latitude = "49°22`48 N",
  longitude = "2°53`00 E",

  effort = c(11L, 23L, 17L, 14L, 13L)[match(local, c("reserve_luvisols", "managed_luvisols", "managed_cambisols", "managed_podzols", "managed_gleysols"))],
  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  alpha_grain = 800L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",

  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the sampled areas",

  gamma_bounding_box = 14414L,
  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "ecosystem",

  comment = "Extracted from Closset et al 2018 10.1111/1365-2745.13118 supplementary material. Effort is comparable between the original survey and the re-sampling. 11 to 23 800m2 plots per soil type. 'In 1970, a vegetation survey of the Compiègne forest was carried out by a senior botanist [...]. Relevés were done in temporary plots of 800 m2. For each relevé, he exhaustively recorded all vascular plant species within each vegetation layer (tree: >7 m, shrub: 1–7 m, herb <1 m) [...]. Two of us (DCK and GD) implemented a resurvey in 2015, using the same method (plot size, season) as Tombal in order to maximize reliability of the comparison between the two surveys.'",
  comment_standardisation = "none needed"

)][, gamma_sum_grains := effort * 0.8]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
