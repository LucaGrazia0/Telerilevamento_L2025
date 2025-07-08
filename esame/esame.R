# ESAME DI TELERIVAMENTO GEOECOLOGICO - GRAZIA LUCA - MAT. 1191463

# PACCHETTI UTILIZZATI:
library(terra) #attraverso la funzione rast() posso importare immagini .tif
library(imageRy) #visualizzazione e analisi immagini
library(viridis) #serve per creare plot di immagini con differenti palette di colori 
library(ggridges) #permette di creare i plot ridgeline
library(ggplot2) #permette di creare grafici a barre
library(patchwork) # package needed to couple graphs


#Cosa analizzerò:
#il seguente documento analizza come, nell'area del paese di blatten (comune del canton Vallese), sia avvenuta una variazione della copertura del suolo a seguito di una frana staccatasi dal ghiacciaio Birch il 28 maggio 2025 e la conseguente formazione di un lago creatosi dallo sbarramento duvuto alla frana.
#La variazione viene analizzata attraverso l'applicazione di indici spettrali e analisi multitemporale

#Ricerca dei dati:
#per ottenere le immagini da analizzare ho utilizzato il seguente sito: https://earthengine.google.com/ 
#utilizzando Sentinel, ho applicato il codice JavaScript fornito da Rocio Beatriz Cortes Lobos durante le lezioni modificando:
  # 1) l'area da analizzare
  # 2) numero di bande 1=red, 2=green, 3=blue e 8=NIR
  # 3) le date di acquisizione 

# una volta modificati questi parametri, utilizzando sempre imamgini con copertura nuvolosa <20%, ho proceduto a salvare e scaricare le immagini 


# I due codici seguenti utilizzano il linguaggio di programmazione java script all'interno della piattaforma Google Earth Engine per ottenere le immagini relative al paese di Blatten e  frana staccatasi da ghiacciaio Birch il 28 maggio 2025

# Primo script per ottenere l'immagine "blattenpre1": riporta ula media composita di immagini che vanno dal 2025-05-01 al 2025-05-25 selezionando solo quelle con una copertura nuvolosa inferiore al 20%; le bande sono relative al rosso, verde, blu e NIR.

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
                   .filterDate('2025-05-01', '2025-05-25')              // Filter by date                                   // Filter by AOI
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
  fileNamePrefix: 'blattenpre1',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});



# Secondo script per ottenere l'immagine "blattenpostNIR": riporta la media composita di immagini che vanno dal 2025-05-30 al 2025-06-30 selezionando solo immagini con una copertura nuvolosa <20% e le bande relative al rosso, verde, blu e NIR.

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



#Analisi dei dati satellitari:
  #usando Google Earth Engine scarico e salvo le immagini su google drive, sucessivamente eseguo il download salvandole in formato .tif

setwd("/Users/lucagrazia/Downloads") #imposto la working directory

  #plotto immagine "blattenpre" che si riferisce al mese precedente alla frana
blattenpre=rast("blattenpre1.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino
plot(blattenpre) #plotto l'immagine per visuallizzarla
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima") #plot RGB per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
dev.off()


#ripeto la stessa funzione con la seconda immagine 

  #plotto immagine "blattenpost" che si riferisce al mese successivo alla frana
blattenpost=rast("blattenpostNIR.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino
plot(blattenpost) #plotto l'immagine per visuallizzarla
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo") #plot RGB per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
dev.off()

#dato che ho scaricato e visualizzato le due immagini singolarmente ora imposto un pannello multiframe per visualizzarle entrambe 

png("blattenrgb.png") #funzione che mi permette di salvare una copia dell'immagine in formato.png
im.multiframe(1,2) #con questa funzione apro un pannello multiframe che mi permette di vedere le 2 immagini una affiancate (una linea, due colonne) 
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima")
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo")
dev.off()


# Confronto le due immagini mettendo in risalto solo le corrispettive al Near Infra-Red, cioè la banda 8: 

png("blattenbandaNIR.png")
im.multiframe(1,2) 
plot(blattenpre[[4]], stretch="lin", main = "BlattenpreNIR", col=inferno(100)) #attraverso viridis utilizza la palette di colori "inferno" specificando il numero di colori che voglio nella scala per uniformarlo alla seconda immagine
plot(blattenpost[[4]], stretch="lin", main = "BlattenpostNIR", col=inferno(100))
dev.off()

# Visualizzazione del suolo nudo rispetto alla vegetazione impostando sulla banda del blu la banda dell'infrarosso in, questo fa risaltare la vegetazione di colore blu e tutto quello che non è vegetazione nella sccala del giallo, solitamente è usato per evidenziare il suolo nudo:

png("blattensuolonudo.png")
im.multiframe(1,2)
plotRGB(blattenpre, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Prima") 
plotRGB(blattenpost, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Dopo")
dev.off()

#si può notare che il colore blu è aumentato nella seconda immagine probabilemte perché è avvenuto uno scioglimento rapido della copertura nevosa

#INDICI SPETTRALI 

#DIFFERENT VEGETATION INDEX - DVI
  #Questo indice che ci dà informazione sullo stato di salute delle piante attraverso la riflettanza della vegetazione nelle bande del rosso e NIR. In caso di stress le cellule a palizzata collassano, allora quindi la riflettanza nel NIR sarà più bassa.
  #Calcolo: DVI= NIR - red

DVIpre=im.dvi(blattenpre, 4, 1) #funzione im.dvi di imageRy che prende l'immagine da analizzare e automaticamente sottrae dal NIR la banda del RED
plot(DVIpre, col=inferno(100))
dev.off()

DVIpost=im.dvi(blattenpost, 4, 1) 
plot(DVIpost, col=inferno(100))
dev.off()

# Creo un pannello multiframe per confrontare le immagini su cui è stato calcolalto il DVI:
png("blattenDVI.png")
im.multiframe(1,2)
plot(DVIpre, stretch = "lin", main = "pre_frana", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "post_frana", col=inferno(100))
dev.off()

#nelle immagini si vede chiaramente la distribuzione della biomassa vegetale (visibile in giallo) che si protrae nella valle, la differenza principale sorge nella seconda immagine dove c'è un chiaro segno della frana rappresentato da un'area più scura 


#NORMALIZED DIFFERENCE VEGETATION INDEX
  #Un secondo indice per l'analisi della vegetazione, dato che i valori vengono normalizzati  tra -1 e +1 possiamo attuare analisi che sono state acquisite in tempi diversi come ad esempio nel caso di Blatten per verificare l'impatto della frana.
  # Calcolo: NDVI= (NIR - red) / (NIR + red)

NDVIprima =im.ndvi(blattenpre, 4, 1) #anche in questo caso attraverso la funzione im.ndvi() di imageRy si semplifica il calcolo
plot(NDVIprima, stretch = "lin", main = "NDVIpre", col=inferno(100))
dev.off()

NDVIdopo =im.ndvi(blattenpost, 4, 1) 
plot(NDVIdopo, stretch = "lin", main = "NDVIpost", col=inferno(100))
dev.off()

png("blattenNDVI.png")
im.multiframe(1,2)
plot(NDVIprima, stretch = "lin", main = "NDVIprima_frana", col=inferno(100))
plot(NDVIdopo, stretch = "lin", main = "NDVIdopo_frana", col=inferno(100))
dev.off()

#nella prima imamgine si può apprezzare come la vegetazione del fondovalle sia sana e abbia una buona copertura nonostante la presenza elevata di neve,mostrando comunque vaolori vicini allo 0.8; nella seconda immagine è presente una grossa massa inerte nel centro che è rappresentata dalla frana.

#NORMALIZED DIFFERENCE WATER INDEX 
  # Indice usato in telerilevamento per identificare l'acqua superficiale nelle immagini satellitari.
  # NDWI= (Green-NIR)/(Green+NIR)

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

# guardando il funzionamento della funzione im.ndvi(), dato che è simile al calcolo di ndwi, ho cercato di cambiare i dati immessi per crearne una che potesse restituirmi NDWI
im.ndwi <- function(x, green, nir){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(green, "numeric") && !inherits(nir, "numeric")) {
    stop("green and NIR layers should be indicated with a number")
  }
  
  ndwi = (x[[green]] - x[[nir]]) / (x[[green]] + x[[nir]])
 
  return(ndwi)
  
}

NDWIprima= im.ndwi(blattenpre,2,4)
plot(NDWIprima, stretch = "lin", main = "NDWI_prima", col=inferno(100))


NDWIdopo=im.ndwi(blattenpost,2,4)
plot(NDWIdopo, stretch = "lin", main = "NDWI_dopo", col=inferno(100))

png("blattenNDWI.png")
im.multiframe(1,2)
plot(NDWIprima, stretch = "lin", main = "NDWI_prima", col=inferno(100))
plot(NDWIdopo, stretch = "lin", main = "NDWI_dopo", col=inferno(100))
dev.off()

#si può notare agevolmente un accumulo di acqua a mmonte della frana dovuto allo sbarramento del torrente Lonza


#ANALISI MULTITEMPORALE
  #Analisi attraverso R per vedere come un'area specifica cambia nel tempo

blatten_diff=blattenpre[[1]]-blattenpost[[1]] #rosso
blatten_NDVIdiff=NDVIprima-NDVIdopo

png("blattenmultitemp.png")
im.multiframe(1,2)
plot(blatten_diff, main = "BLATTEN PRIMA E DOPO:\ndifferenza banda del rosso", col=rocket(100)) #La banda del rosso (Red) è molto sensibile alla vegetazione e ai materiali di superficie.
plot(blatten_NDVIdiff, main = "BLATTEN PRIMA E DOPO:\ndifferenza NDVI", col=rocket(100)) #differenza NDVI tra le due immagini, visibile la frana
dev.off()

#funzione draw di terra
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten_POST (RGB)")
crop_blatten = draw(x="extent", col="red", lwd=2) #rettangolo, rosso, di spessore 2
blatten_post_crop = crop(blattenpost, crop_blatten)
blatten_pre_crop = crop(blattenpre, crop_blatten)

blatten_ndvi_pre_crop = crop(NDVIprima, crop_blatten)
blatten_ndvi_post_crop = crop(NDVIdopo, crop_blatten)

png("blattencrop.png")
im.multiframe(2,2)                                           # creo multiframe e plotto le nuove immagini croppate
plotRGB(blatten_pre_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "maggio")
plotRGB(blatten_post_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "giugno")
plot(blatten_ndvi_pre_crop, main = "NDVI maggio")
plot(blatten_ndvi_post_crop, main = "NDVI giugno")
dev.off()

blatten_ridg=c(blatten_ndvi_pre_crop, blatten_ndvi_post_crop) #creazione vettore per visualizzare le due immagini contemporaneamente
names(blatten_ridg) =c("NDVI MAGGIO", "NDVI GIUGNO") #vettore con i nomi relativi alle due immagini
png("blatten_ridgeline1.png")
im.ridgeline(blatten_ridg, scale=0.5, palette="viridis")    # applico la funzione im.ridgeline del pacchetto imageRy
dev.off()


#i valori che si possono vedere sono molto descrittivi dell'area, abbiamo infatti un picco a maggio dovuto a valori intorno allo 0 che indicano principalmente l'alta quantità di neve 
#nel mese di giugno si vede un aumento nei valori compresi tra 0 e 0.1 che indicano il nutevole ammasso di rocce e materiali inerti staccatosi dal versante dela montagna, si nota anche un aumento della vegetaizione circostante



#Classificazione immagini
  # visualizzare la variazione percentuale di NDVI nel sito, prima suddivido i pixel in due classi e poi, tramite un grafico a barre del pacchetto ggplot2, mostro la variazione 
blatten_maggio_classi = im.classify(blatten_ndvi_pre_crop, num_clusters=2)            # divido i pixel di ogni immagine in due cluster per capire come sono stati classificati  
blatten_giugno_classi = im.classify(blatten_ndvi_post_crop, num_clusters=2)

png("visualizzazione_classi_ndvi1.png")
im.multiframe(2,2)
plot(blatten_maggio_classi, main = "Pixel prima della frana")
plot(blatten_giugno_classi, main = "Pixel dopo la frana")
plot(blatten_maggio_classi - blatten_giugno_classi, main = "Differenza Pixel NDVI blatten\n(maggio-giugno)")
dev.off()

#valori:
  #1 valori alti NDVI -> vegetazione
  #2 valori bassi NDVI -> roccia

  #la differenza è visibile attraverso il colore viola che mostra una differernza sostanziale 

#calcolo frequenza con freq() per contare il numero di celle (pixel) per ciascun valore presente in un oggetto raster
#ncell per capire il totale di pixel 
#per le proporzioni si fa freq/tot per conoscere la percentuale di immagine coperta da ciascuna classe. È fondamentale per interpretare, confrontare e analizzare i risultati di una classificazione raster.

percentuale_maggio = freq(blatten_maggio_classi) * 100 / ncell(blatten_maggio_classi)
percentuale_maggio
         layer       value    count
1 0.000652018 0.000652018 66.15309    #classe 1 è 66%
2 0.000652018 0.001304036 33.84691    #classe 2 è 34%


percentuale_giugno = freq(blatten_giugno_classi) * 100 / ncell(blatten_giugno_classi)
percentuale_giugno
 layer       value    count
1 0.000652018 0.000652018 60.91543    #classe 1 è 61%
2 0.000652018 0.001304036 39.08457    #classe 2 è 39%

NDVI = c("basso", "elevato")              # creo vettore in cui inserisco i nomi relativi ai valori NDVI
maggio = c(34, 66)                        # creo vettore con le percentuali relative al mese di maggio
giugno = c(39, 61)                        # creo vettore con le percentuali relative al mese di giugno 
tabout = data.frame(NDVI, maggio, giugno)     #creo dataframe

tabout
     NDVI   maggio giugno
1   basso     34     39
2 elevato     66     61


#funzione ggplot, funzione di base per fare i plot:
  #tabout è il valore in imput
  #aes imposta le aesthetic mappings (cioè, cosa va sull’asse X e sull’asse Y, riempimento e colore)
  #geom_bar serve per descrivere il tipo di grafico bar=istogramm
  #ylim(c(0,100)) per mantere univoca una scala di riproduzione

ggplotmaggio1 = ggplot(tabout, aes(x=NDVI, y=maggio, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotgiugno1 = ggplot(tabout, aes(x=NDVI, y=giugno, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))

png("ggplot1.png") 
ggplotmaggio1 + ggplotgiugno1
+ plot_annotation(title = "Valori NDVI (espressi in superficie) nell'area di Blatten")    # creo un plot con i due grafici, plot annotation mi serve per aggiungere un titolo
dev.off()


