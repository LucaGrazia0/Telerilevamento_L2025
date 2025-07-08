# ESAME DI TELERILEVAMENTO GEOECOLOGICO
> ## Grazia Luca
>> ### matricola n. 1191463

## Le conseguenze della frana che ha interessato l'abitato di Blatten nella valle del Lötschental🏔️
Il 28/05, alle 15.24, una frana di eccezionale portata, innescata dal crollo del ghiacciaio Birch, ha sepolto circa il 90% del territorio comunale di Blatten, travolgendo ampie porzioni del villaggio con una colata composta da ghiaccio, fango e detriti rocciosi. Il materiale franato ha ostruito il corso del fiume Lonza, che attraversa la valle, formando un lago temporaneo a monte dell’area interessata.

**In questo elaborato è stato quindi analizzata, tramite telerilevamento satellitare, la variazione della copertura del suolo a seguito di una frana e la conseguente formazione del lago a monte**

In particolare è stata confrontata l'area attraverso due immagini che si riferiscono a due differenti momenti:
+ dal **01/05** al **25/05**, il mese precedente alla frana
+ dal **30/05** al **30/06**, il mese successivo alla frana

![image](https://github.com/user-attachments/assets/34b45dbb-6912-4c2b-924f-9135dd4f9c52)
>*l'area presa in considerazione, Lötschental, distretto di Raron Occidentale*


## Acquisizione delle immagini satellitari 🛰️📡
### Download immagini 
Attraverso [Google Earth Engine](https://earthengine.google.com) ho scaricato le immagini satellitari provenienti dalla missione ESA Sentinel 2,

Per l'area di studio sono state scelte due immagini che si riferiscono al mese precedente e successivo alla frana, nello specifico:
+ la prima imamgine si riferisce al mese di maggio, la vegetazione è in piena attività fotosintetica, ma si nota ancora una buona copertura nevosa nonostante la tarda primavera, questo fattore è dovuto al fatto che il comune di Blatten è il più elevato della valle del Lötschental (1540m s.l.m.)
+ la secoda immagine si riferisce al mese di giugno, si può vedere infatti come un rapido incremento delle temperature abbia sciolto la maggio parte della neve nella bassa vallata

Le immagini utilizzate sono la mediana composita delle immagini relative al periodo indicato, un filtro ulteriore è dato dal filtro sulla copertura nuvolosa che restituisce immagini con meno del 20% di nuvole

``` JavaScript
var aoi = 
    /* color: #98ff00 */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[7.742448332898286, 46.44857310593719],
          [7.742448332898286, 46.380877440396624],
          [7.92337942420688, 46.380877440396624],
          [7.92337942420688, 46.44857310593719]]], null, false);
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
  image: composite.select(['B4', 'B3', 'B2', 'B8']),  // Select RGB bands and NIR
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'blattenpre1',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});
```
Il codice è stato utilizzato per ottenere l'immagine "blattenpre1" per poi essere riutilizzato una seconda volta per scaricare l'immagine relativa al mese di giugno "blattenpostNIR".

``` JavaScript
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
  image: composite.select(['B4', 'B3', 'B2', 'B8']),  // Select RGB bands and NIR
  description: 'Sentinel2_Median_Composite',
  folder: 'GEE_exports',                        // Folder in Google Drive
  fileNamePrefix: 'blattenpostNIR',
  region: aoi,
  scale: 10,                                    // Sentinel-2 resolution
  crs: 'EPSG:4326',
  maxPixels: 1e13
});
```

## Importazione immagini su R e visualizzazione

Sono stati utilizzati i seguenti pacchetti per importazione, visualizzazione eanalisi delle immagini:
+ ***terra*** pacchetto per importare immagini; funzione rast()
+ ***imageRy*** visualizzazione e analisi delle immagini; funzioni im.plotRGB(), im.dvi() e im.ndvi()
+ ***viridis*** palette di colori
+ ***ggridges*** creazione di plot ridgeline
+ ***ggplot2*** creazione di grafici a barre 
+ ***patchwork*** unione dei grafici creati con ggplot2


Dopo aver scaricato le immagini su google drive in formato .tif,  eseguo il download salvandole nella cartella apposita

Per prima cosa imposto la directory di lavoro
```R
setwd("/Users/lucagrazia/Downloads") #imposto la working directory
```

Per poi importare le immagini su R attraverso la funzione rast() e visualizzarle con i colori reali im.plotRGB() impostando un pannello multiframe epr vederle entrambe
```R
blattenpre=rast("blattenpre1.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino
blattenpost=rast("blattenpostNIR.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino

png("blattenrgb.png") #funzione che mi permette di salvare una copia dell'immagine in formato.png
im.multiframe(1,2) #con questa funzione apro un pannello multiframe che mi permette di vedere le 2 immagini una affiancate (una linea, due colonne) 
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima")#plot RGB per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo")
dev.off()
```
![blattenrgb](https://github.com/user-attachments/assets/5669853d-edd2-436e-9838-2235a0a0161d)
>*le differenze tra prima e dopo la frana*

Confronto le due immagini mettendo in risalto solo le corrispettive bande Near Infra-Red
```R
png("blattenbandaNIR.png")
im.multiframe(1,2) 
plot(blattenpre[[4]], stretch="lin", main = "BlattenpreNIR", col=inferno(100)) #attraverso viridis utilizza la palette di colori "inferno" specificando il numero di colori che voglio nella scala per uniformarlo alla seconda immagine
plot(blattenpost[[4]], stretch="lin", main = "BlattenpostNIR", col=inferno(100))
dev.off()
```
![blattenbandaNIR](https://github.com/user-attachments/assets/431a9903-7ebe-4a69-8f13-bc3b2af8d05c)
>*si può intravedere una massa nel centro dell'immagine che corrisponde alla frana*

Visualizzo quindi il suolo nudo utilizzando la banda **NIR**, vicino infrarosso, al posto della banda blu, questo fa risaltare la vegetazione di colore blu e tutto quello che non è vegetazione nella sccala del giallo, solitamente è usato per evidenziare il suolo nudo
```R
png("blattensuolonudo.png")
im.multiframe(1,2)
plotRGB(blattenpre, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Prima") #imposto il NIR sulla banda Blu
plotRGB(blattenpost, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Dopo")
dev.off()
```
![blattensuolonudo](https://github.com/user-attachments/assets/23d8fe19-198b-4b20-93fd-b61debeef27b)
>*il colore blu è aumentato nella seconda immagine a causa dello scioglimento della copertura nevosa*

## Analisi immagini 
### Indici spettrali
##### DIFFERENT VEGETATION INDEX - DVI
Questo indice che ci dà informazione sullo stato di salute delle piante attraverso la riflettanza della vegetazione nelle bande del rosso e NIR. In caso di stress le cellule a palizzata diminuiscono la loro capacità fotosintetica per ridurre la perdita d'acqua, per cui la riflettanza nel NIR sarà più bassa.
Calcolo: DVI= NIR - red
```R
DVIpre=im.dvi(blattenpre, 4, 1) #funzione im.dvi di imageRy che prende l'immagine da analizzare e automaticamente sottrae dal NIR la banda del RED
plot(DVIpre, col=inferno(100))
dev.off()

DVIpost=im.dvi(blattenpost, 4, 1) 
plot(DVIpost, col=inferno(100))
dev.off()

#Creo un pannello multiframe per confrontare le immagini su cui è stato calcolalto il DVI:
png("blattenDVI.png")
im.multiframe(1,2)
plot(DVIpre, stretch = "lin", main = "pre_frana", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "post_frana", col=inferno(100))
dev.off()
```
![blattenDVI](https://github.com/user-attachments/assets/eeed0cf9-7636-49d7-afbd-700a490742d5)
>*si vede chiaramente la distribuzione della biomassa vegetale (visibile in giallo) che si estende nella valle, la differenza principale sorge nella seconda immagine dove c'è un chiaro segno della frana rappresentato da un'area più scura*

#### NORMALIZED DIFFERENCE VEGETATION INDEX
Un secondo indice per l'analisi della vegetazione, dato che i valori vengono normalizzati  tra -1 e +1 possiamo attuare analisi su immagini che sono state acquisite in tempi diversi come ad esempio nel caso di Blatten per verificare l'impatto della frana.
Calcolo: NDVI= (NIR - red) / (NIR + red)
```R
NDVIprima =im.ndvi(blattenpre, 4, 1) #anche in questo caso attraverso la funzione im.ndvi() di imageRy si semplifica il calcolo
plot(NDVIprima, stretch = "lin", main = "NDVIprima_frana", col=inferno(100))
dev.off()

NDVIdopo =im.ndvi(blattenpost, 4, 1) 
plot(NDVIdopo, stretch = "lin", main = "NDVIdopo_frana", col=inferno(100))
dev.off()

png("blattenNDVI.png")
im.multiframe(1,2)
plot(NDVIprima, stretch = "lin", main = "NDVIprima_frana", col=inferno(100))
plot(NDVIdopo, stretch = "lin", main = "NDVIdopo_frana", col=inferno(100))
dev.off()
```
![blattenNDVI](https://github.com/user-attachments/assets/70af042c-ede0-4369-9b24-bfa112a2e277)
>*nella prima imamgine si può apprezzare come la vegetazione del fondovalle sia sana e abbia una buona copertura nonostante la presenza cospicua di neve, mostrando comunque vaolori vicini allo 0.8; nella seconda immagine rimane sempre una vegetazione florida ma è presente una grossa massa inerte nel centro che è rappresentata dalla frana.*

#### NORMALIZED DIFFERENCE WATER INDEX 
Indice usato in telerilevamento per identificare l'acqua superficiale nelle immagini satellitari.
NDWI= (Green-NIR)/(Green+NIR)
```R
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
```
Osservando il funzionamento della funzione im.ndvi(), ho notato una certa somiglianza al calcolo dell'indice NDWI, ho cercato quindi di cambiare i parametri immessi per creare una funzione che potesse restituirmi NDWI velocemente

``` R
#imposto la funzione 
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

#utilizzo la funzione
NDWIprima= im.ndwi(blattenpre,2,4)
NDWIdopo=im.ndwi(blattenpost,2,4)

png("blattenNDWI.png")
im.multiframe(1,2)
plot(NDWIprima, stretch = "lin", main = "NDWI_prima", col=inferno(100))
plot(NDWIdopo, stretch = "lin", main = "NDWI_dopo", col=inferno(100))
dev.off()
```
![blattenNDWI](https://github.com/user-attachments/assets/3e21f934-881a-492a-8038-b3d0278bac5c)

>* in giallo si può notare un accumulo di acqua del torrente Lonza a monte della frana dovuto allo sbarramento della massa rocciosa*

### Analisi Multitemporale
Analisi attraverso R per vedere come un'area specifica cambia nel tempo, in questo caso si analizza:
+ **banda del rosso**, molto sensibile alla vegetazione e ai materiali di superficie
+ **NDVI**

```R
blatten_diff=blattenpre[[1]]-blattenpost[[1]] #rosso
blatten_NDVIdiff=NDVIprima-NDVIdopo

png("blattenmultitemp.png")
im.multiframe(1,2)
plot(blatten_diff, main = "BLATTEN PRIMA E DOPO:\ndifferenza banda del rosso", col=rocket(100)) #La banda del rosso (Red) è molto sensibile alla vegetazione e ai materiali di superficie.
plot(blatten_NDVIdiff, main = "BLATTEN PRIMA E DOPO:\ndifferenza NDVI", col=rocket(100)) #differenza NDVI tra le due immagini, visibile la frana
dev.off()
```
![blattenmultitemp](https://github.com/user-attachments/assets/16e29cd7-5d7a-4e06-a456-effed93f37f3)
>*è visibile una zona di colore diverso nel centro dell'immagine che corrisponde alla frana*

Applico la funzione **draw del pacchetto terra** per selezionare un'area meno ampia dell'immagine, questo è importante in questo caso perchè lo scioglimento della neve ha modificato rapidamente l'NDVI per cui ho scelto un'area più piccola per attuare le analisi ulteriori

```R
#funzione draw di terra
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten_POST (RGB)")
crop_blatten = draw(x="extent", col="red", lwd=2) #rettangolo, rosso, di spessore 2
blatten_post_crop = crop(blattenpost, crop_blatten)
blatten_pre_crop = crop(blattenpre, crop_blatten)

blatten_ndvi_pre_crop = crop(NDVIprima, crop_blatten)
blatten_ndvi_post_crop = crop(NDVIdopo, crop_blatten)

png("blattencrop.png")
im.multiframe(2,2) # creo multiframe
plotRGB(blatten_pre_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "maggio")
plotRGB(blatten_post_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "giugno")
plot(blatten_ndvi_pre_crop, main = "NDVI maggio")
plot(blatten_ndvi_post_crop, main = "NDVI giugno")
dev.off()
```
![blattencrop](https://github.com/user-attachments/assets/271554fb-c7dd-4369-be99-73942de5aed7)
>*le aree selezionate*

Proseguo facendo un'analisi ridgeline sulle immagini croppate che permette di creare due **curve di distribuzione** utili per valutare possibili variazioni nel tempo nella frequenza dell'NDVI

```R
blatten_ridg=c(blatten_ndvi_pre_crop, blatten_ndvi_post_crop) #creazione vettore per visualizzare le due immagini contemporaneamente
names(blatten_ridg) =c("NDVI MAGGIO", "NDVI GIUGNO") #vettore con i nomi relativi alle due immagini
png("blatten_ridgeline1.png")
im.ridgeline(blatten_ridg, scale=0.5, palette="viridis")    # applico la funzione im.ridgeline del pacchetto imageRy
dev.off()
```

![blatten_ridgeline1](https://github.com/user-attachments/assets/9db5216c-33bd-4005-a502-7fcffad90b6a)
>*distribuzioni di NDVI nelle due immagini croppate*

Dal grafico si possono apprezzare due fattori:
+ **NDVI di maggio** può rappresentare una situazione di tarda primavera in zone di alta montagna
+ **NDVI** di giugno mostra un aumento dei valori di NDVI basso (si nota anche la presenza dello speccio d'acqua) causati dalla presenza della frana, mostra inoltre un aumento dei valori di NDVI alto dato che la vegetazione è in piena attività fotosintetica


### Classificazione delle immaigni

Visualizzare la variazione percentuale di NDVI nel sito, prima suddivido i pixel in due classi e poi, tramite un grafico a barre del pacchetto ggplot2, mostro la variazione
```R
blatten_maggio_classi = im.classify(blatten_ndvi_pre_crop, num_clusters=2)   # divido i pixel di ogni immagine in due cluster per capire come sono stati classificati  
blatten_giugno_classi = im.classify(blatten_ndvi_post_crop, num_clusters=2)

png("visualizzazione_classi_ndvi1.png")
im.multiframe(2,2)
plot(blatten_maggio_classi, main = "Pixel prima della frana")
plot(blatten_giugno_classi, main = "Pixel dopo la frana")
plot(blatten_maggio_classi - blatten_giugno_classi, main = "Differenza Pixel NDVI blatten\n(maggio-giugno)")
dev.off()
```
![visualizzazione_classi_ndvi1](https://github.com/user-attachments/assets/857f3ab1-554c-47ab-ba6f-1bd20dcff57f)

valori:
+1 valori NDVI -> vegetazione
+2 valori NDVI -> roccia

la differenza è visibile attraverso il colore viola che mostra una differenza sostanziale evidenziando l'area della frana

Alcune informazioni:
+calcolo frequenza con freq() per contare il numero di celle (pixel) per ciascun valore presente in un oggetto raster
+ncell per capire il totale di pixel 
+per le proporzioni si fa freq/tot per conoscere la percentuale di immagine coperta da ciascuna classe. È fondamentale per interpretare, confrontare e analizzare i risultati di una classificazione raster.

