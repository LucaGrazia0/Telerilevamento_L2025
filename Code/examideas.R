#Luca Grazia 

# PACCHETTI USATI:
library(terra) #funzione rast() per SpatRaster
library(imageRy) #funzione im.plotRGB()
library(viridis) #serve per creare plot di immagini con differenti palette di colori di viridis
library(ggridges) #permette di creare i plot ridgeline
library(ggplot2) #permette di attuare la classificazione tramite  ggplot


# I due codici seguenti utilizzano il linguaggio di programmazione java script all'interno della piattaforma Google Earth Engine per ottenere le immagini relative al paese di Blatten e  frana staccatasi da ghiacciaio Birch il 28 maggio 2025
# Script per ottenere l'immagine "blattenpreNIR": riporta una collection di immagini che vanno dal 2025-01-01 al 2025-05-25 selezionando solo immagini con una copertura nuvolosa <20% e le bande relative al rosso, verde, blu e NIR.

// ==============================================
// Sentinel-2 Surface Reflectance - Cloud Masking and Visualization
// https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED
// ==============================================

// ==============================================
// Function to mask clouds using the QA60 band
// Bits 10 and 11 correspond to opaque clouds and cirrus
// ==============================================
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Keep only pixels where both cloud and cirrus bits are 0
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Apply the cloud mask and scale reflectance values (0–10000 ➝ 0–1)
  return image.updateMask(mask).divide(10000);
}

// ==============================================
// Load and Prepare the Image Collection
// ==============================================

// Load Sentinel-2 SR Harmonized collection (atmospherical correction already done)
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                   .filterBounds(aoi)
                   .filterDate('2025-01-01', '2025-05-25')              // Filter by date                                   // Filter by AOI
                   .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Only images with <20% cloud cover
                   .map(maskS2clouds);                                  // Apply cloud masking

// Print number of images available after filtering
print('Number of images in collection:', collection.size());

// ==============================================
// Create a median composite from the collection
// Useful when the AOI overlaps multiple scenes or frequent cloud cover
// ==============================================
var composite = collection.median().clip(aoi);

// ==============================================
// Visualization on the Map
// ==============================================

Map.centerObject(aoi, 10); // Zoom to the AOI

// Display the first image of the collection (GEE does this by default)
Map.addLayer(collection, {
  bands: ['B4', 'B3', 'B2', 'B8'],  // True color: Red, Green, Blue, NIR
  min: 0,
  max: 0.3
}, 'First image of collection');

// Display the median composite image
Map.addLayer(composite, {
  bands: ['B4', 'B3', 'B2', 'B8'],
  min: 0,
  max: 0.3
}, 'Median composite');

// ==============================================
// Export to Google Drive
// ==============================================

// Export the median composite
Export.image.toDrive({
  image: composite.select(['B4', 'B3', 'B2', 'B8']),  // Select RGB bands
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'blattenpreNIR',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});



# Script per ottenere l'immagine "blattenpostNIR": riporta una collection di immagini che vanno dal 2025-05-30 al 2025-06-30 selezionando solo immagini con una copertura nuvolosa <20% e le bande relative al rosso, verde, blu e NIR.

// ==============================================
// Sentinel-2 Surface Reflectance - Cloud Masking and Visualization
// https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED
// ==============================================

// ==============================================
// Function to mask clouds using the QA60 band
// Bits 10 and 11 correspond to opaque clouds and cirrus
// ==============================================
function maskS2clouds(image) {
  var qa = image.select('QA60');
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Keep only pixels where both cloud and cirrus bits are 0
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
               .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  // Apply the cloud mask and scale reflectance values (0–10000 ➝ 0–1)
  return image.updateMask(mask).divide(10000);
}

// ==============================================
// Load and Prepare the Image Collection
// ==============================================

// Load Sentinel-2 SR Harmonized collection (atmospherical correction already done)
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                   .filterBounds(aoi)
                   .filterDate('2025-05-30', '2025-06-30')              // Filter by date                                   // Filter by AOI
                   .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Only images with <20% cloud cover
                   .map(maskS2clouds);                                  // Apply cloud masking

// Print number of images available after filtering
print('Number of images in collection:', collection.size());

// ==============================================
// Create a median composite from the collection
// Useful when the AOI overlaps multiple scenes or frequent cloud cover
// ==============================================
var composite = collection.median().clip(aoi);

// ==============================================
// Visualization on the Map
// ==============================================

Map.centerObject(aoi, 10); // Zoom to the AOI

// Display the first image of the collection (GEE does this by default)
Map.addLayer(collection, {
  bands: ['B4', 'B3', 'B2', 'B8'],  // True color: Red, Green, Blue, NIR
  min: 0,
  max: 0.3
}, 'First image of collection');

// Display the median composite image
Map.addLayer(composite, {
  bands: ['B4', 'B3', 'B2', 'B8'],
  min: 0,
  max: 0.3
}, 'Median composite');

// ==============================================
// Export to Google Drive
// ==============================================

// Export the median composite
Export.image.toDrive({
  image: composite.select(['B4', 'B3', 'B2', 'B8']),  // Select RGB bands
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'blattenpostNIR',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});


#Analisi dei dati satellitari
#usando google earth engine ottengo le immagini su google drive, le scarico in formato .tif
#successivamente imposto la working directory per visuallizzare e analizzare queste immagini

setwd("/Users/lucagrazia/Downloads")

#blattenpre
blattenpre=rast("blattenpre1.tif") #importo e nomino il raster
plot(blattenpre) #visualizzo attraverso il plot l'immagine
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima") #plot RGB per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
dev.off()


#ripeto la stessa funzione con la seconda immagine 

#blattenpost
blattenpost=rast("blattenpostNIR.tif") #importo e nomino il raster
plot(blattenpost) #visualizzo attraverso il plot l'immagine
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo") #plot RGB per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
dev.off()

#dato che ho scaricato e visualizzato le due immagini singolarmente ora imposto un pannello multiframe per visualizzarle entrambe 
png("blattenrgb.png")
im.multiframe(1,2) #con questa funzione apro un pannello multiframe che mi permette di vedere le 2 immagini una affiancate 
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima")
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo")
dev.off()

# Creo un pannello multiframe per confrontare le 4 bande che costituiscono ogniuna delle due immagini:
# Cambio i colori per migliorare la visualizzazione utilizzando il colore "magma" dalla palette dei colori di viridis.
png("blattenbande.png")
im.multiframe(2,4) #(layout: 2 righe, 4 colonne)
plot(blattenpre[[1]], col = magma(100), main = "Pre - Banda 1")
plot(blattenpre[[2]], col = magma(100), main = "Pre - Banda 2")
plot(blattenpre[[3]], col = magma(100), main = "Pre - Banda 3")
plot(blattenpre[[4]], col = magma(100), main = "Pre - Banda 8")
plot(blattenpost[[1]], col = magma(100), main = "Post - Banda 1")
plot(blattenpost[[2]], col = magma(100), main = "Post - Banda 2")
plot(blattenpost[[3]], col = magma(100), main = "Post - Banda 3")
plot(blattenpost[[4]], col = magma(100), main = "Post - Banda 8")

dev.off()

# Confronto delle due immagini mettendo in risalto solo le corrispettive bande 8: 
png("blattenbandanir.png")
im.multiframe(1,2) #isolo e visualizzo solo le bande 8 relative al NIR delle due immagini una accanto all'altra
plot(blattenpre[[4]], stretch="lin", main = "BlattenpreNIR", col=magma(100))
plot(blattenpost[[4]], stretch="lin", main = "BlattenpostNIR", col=magma(100))
dev.off()

# Visualizzazione del suolo nudo rispetto alla vegetazione impostando sulla banda del blu la banda dell'infrarosso in, questo fa risaltare la vegetazione di colore blu e tutto quello che non è vegetazione nella sccala del giallo, solitamente è usato per evidenziare il suolo nudo
png("blattensuolonudo.png")
im.multiframe(1,2)
plotRGB(blattenpre, r = 1, g = 2, b = 4, stretch="lin", main = "BlattenPre") 
plotRGB(blattenpost, r = 1, g = 2, b = 4, stretch="lin", main = "BlsttenPost")
dev.off()


# Calcolo il DVI: Difference Vegetation Index, è un indice che ci dà informazione sullo stato delle piante, basandosi sulla riflettanza della vegetazione nelle bande del rosso B1 e sulla banda B8 relativa al NIR. Se l’albero è stressato, le cellule a palizzata collassano, allora la riflettanza nel NIR sarà più bassa.
# Calcolo: DVI= NIR - red

DVIpre = blattenpre[[4]] - blattenpre[[1]] #NIR - red

#oppure
DVIpre=im.dvi(blattenpre, 4, 1)
plot(DVIpre)
plot(DVIpre, col=inferno(100))
dev.off()

DVIpost = blattenpost[[4]] - blattenpost[[1]] #NIR - red

#oppure
DVIpost=im.dvi(blattenpost, 4, 1) 
plot(DVIpost)
plot(DVIpost, col=inferno(100))
dev.off()

# Creo un pannello multiframe per confrontare le immagini su cui è stato calcoalto il DVI:
png("blattenDVI.png")
im.multiframe(1,2)
plot(DVIpre, stretch = "lin", main = "pre_frana", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "post_frana", col=inferno(100))
dev.off()

#scrivere che vedo 

#NDVI

NDVIprima = (blattenpre[[4]] - blattenpre[[1]]) / (blattenpre[[4]] + blattenpre[[1]]) # NDVI= (NIR - red) / (NIR + red)
#oppure
NDVIprima =im.ndvi(blattenpre, 4, 1)
plot(NDVIprima, stretch = "lin", main = "NDVIpre", col=inferno(100))
dev.off()

NDVIdopo = (blattenpost[[4]] - blattenpost[[1]]) / (blattenpost[[4]] + blattenpost[[1]]) # NDVI= (NIR - red) / (NIR + red)
#oppure
NDVIdopo =im.ndvi(blattenpost, 4, 1)
plot(NDVIdopo, stretch = "lin", main = "NDVIpost", col=inferno(100))
dev.off()

png("blattenNDVI.png")
im.multiframe(1,2)
plot(NDVIprima, stretch = "lin", main = "NDVIprima_frana", col=inferno(100))
plot(NDVIdopo, stretch = "lin", main = "NDVIdopo_frana", col=inferno(100))
dev.off()

#NDWI (Normalized Difference Water Index) è un indice usato in telerilevamento per identificare l'acqua superficiale nelle immagini satellitari.
#NDWI= (Green-NIR)/(Green+NIR)

#pre
diffpre=blattenpre[[2]]-blattenpre[[4]]
sumpre=blattenpre[[2]]+blattenpre[[4]]
NDWI_pre=diffpre/sumpre
plot(NDWI_pre)

#post
diffpost=blattenpost[[2]]-blattenpost[[4]]
sumpost=blattenpost[[2]]+blattenpost[[4]]
NDWI_post=diffpost/sumpost
plot(NDWI_post)

png("blattenNDVI.png")
im.multiframe(1,2)
plot(NDWI_pre)
plot(NDWI_post)
dev.off()
#si nota un accumulo di acqua prima e dopo


#Analisi multitemporale

blatten_diff=blattenpre[[1]]-blattenpost[[1]] #rosso
blatten_NDVIdiff=NDVIprima-NDVIdopo

png("blattenmultitempo.png")
im.multiframe(1,2)
plot(blatten_diff, main = "BLATTEN PRIMA E DOPO:\ndifferenza banda del rosso")
plot(blatten_NDVIdiff, main = "BLATTEN PRIMA E DOPO:\ndifferenza NDVI")

#inserire la mia funzione


# Per visualizzare graficamente la frequenza dei pixel di ogni immagine per ciascun valore di NDVI si è poi fatta un'analisi ridgeline per apprezzare eventuali variazioni nel tempo nella frequenza di NDVI.
#fare un draw?
blatten_ridl=c(NDVIprima, NDVIdopo)
names(blatten_ridl) =c("NDVI MAGGIO", "NDVI Giugno")
png("blatten_ridgeline.png")
im.ridgeline(blatten_ridl, scale=1, palette="inferno")    # applico la funzione im.ridgeline
dev.off()


# visualizzare la variazione percentuale di NDVI nel sito, tramite un grafico a barre tramite il pacchetto ggplot2
blatten_maggio_class = im.classify(NDVIprima, num_clusters=2)            # divido i pixel di ogni immagine in due classi a seconda dei valori
blatten_giugno_class = im.classify(NDVIdopo, num_clusters=2)

png("visualizzazione_classi_ndvi.png")                                                 # plotto le immagini con i pixel suddivisi nei due cluster per vedere come sono stati classificati e la differenza tra esse
im.multiframe(2,2)
plot(blatten_maggio_class, main = "Pixel prima della frana")
plot(blatten_giugno_class, main = "Pixel dopo la frana")
plot(blatten_maggio_class - blatten_giugno_class, main = "Differenza Pixel NDVI blatten\n(maggio-giugno)")
dev.off()

percentuale_maggio = freq(blatten_maggio_class) * 100 / ncell(blatten_maggio_class)
      layer        value    count
1 6.573217e-05 6.573217e-05 68.71727
2 6.573217e-05 1.314643e-04 31.28273

percentuale_giugno = freq(blatten_giugno_class) * 100 / ncell(blatten_giugno_class)
layer        value    count
1 6.573217e-05 6.573217e-05 59.51122
2 6.573217e-05 1.314643e-04 40.48878

#forse è da cambiare alto e basso
NDVI = c("alto", "basso")                                            # creo vettore con i nomi dei due cluster (valore elevato e basso di NDVI)
maggio = c(68.7, 31.3)                                               # creo vettore con le percentuali per ciascun anno
giugno = c(59.5, 40.5)
tabout = data.frame(NDVI, maggio, giugno)  

NDVI maggio giugno
1  alto   68.7   59.5
2 basso   31.3   40.5

ggplotmaggio = ggplot(tabout, aes(x=NDVI, y=maggio, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotgiugno = ggplot(tabout, aes(x=NDVI, y=giugno, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))

png("ggplot.png")
ggplotmaggio + ggplotgiugno
+ plot_annotation(title = "Valori NDVI (espressi in superficie) nell'area di Blatten")    # creo grafico con entrambi i ggplot creati
dev.off()

#molto probabilmente sfasato dallo scioglimento della neve
