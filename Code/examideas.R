#Luca Grazia 

# PACCHETTI USATI:
library(terra) #funzione rast() per SpatRaster
library(imageRy) #funzione im.plotRGB()
library(viridis) #serve per creare plot di immagini con differenti palette di colori di viridis
library(ggridges) #permette di creare i plot ridgeline



# Idue codici seguenti utilizzano il linguaggio di programmazione java script all'interno della piattaforma Google Earth Engine per ottenere le immagini relative al paese di Blatten e  frana staccatasi da ghiacciaio Birch il 28 maggio 2025
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
  bands: ['B4', 'B3', 'B2', 'B8'],  // True color: Red, Green, Blue
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
  bands: ['B4', 'B3', 'B2', 'B8'],  // True color: Red, Green, Blue
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

im.multiframe(1,2) #con questa funzione apro un pannello multiframe che mi permette di vedere le 2 immagini una affiancate 
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima")
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo")
dev.off()

# Creo un pannello multiframe per confrontare le 4 bande che costituiscono ogniuna delle due immagini:
# Cambio i colori per migliorare la visualizzazione utilizzando il colore "magma" dalla palette dei colori di viridis.
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

im.multiframe(1,2) #isolo e visualizzo solo le bande 8 relative al NIR delle due immagini una accanto all'altra
plot(blattenpre[[4]], stretch="lin", main = "BlattenpreNIR", col=magma(100))
plot(blattenpost[[4]], stretch="lin", main = "BlattenpostNIR", col=magma(100))
dev.off()

# Visualizzazione del suolo nudo rispetto alla vegetazione impostando sulla banda del blu la banda dell'infrarosso in, questo fa risaltare la vegetazione di colore blu e tutto quello che non è vegetazione nella sccala del giallo, solitamente è usato per evidenziare il suolo nudo
im.multiframe(1,2)
plotRGB(blattenpre, r = 1, g = 2, b = 4, stretch="lin", main = "BlattenPre") 
plotRGB(blattenpost, r = 1, g = 2, b = 4, stretch="lin", main = "BlsttenPost")
dev.off()
