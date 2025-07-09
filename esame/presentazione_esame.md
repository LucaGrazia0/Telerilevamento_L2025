# ESAME DI TELERILEVAMENTO GEOECOLOGICO
> ## Grazia Luca
>> ### matricola n. 1191463

## Le conseguenze della frana che ha interessato l'abitato di Blatten nella valle del Lötschental🏔️
Il 28/05, alle 15:24, una frana di eccezionale portata, innescata dal crollo del ghiacciaio Birch, ha sepolto circa il 90% del territorio comunale di Blatten, travolgendo ampie porzioni del villaggio con una colata composta da ghiaccio, fango e detriti rocciosi. Il materiale franato ha ostruito il corso del fiume Lonza, che attraversa la valle, formando un lago temporaneo a monte dell’area interessata.

**In questo elaborato è stata analizzata, tramite telerilevamento satellitare, la variazione della copertura del suolo a seguito di una frana e la conseguente formazione del lago a monte** attraverso il confronto di due immagini che si riferiscono al mese precedente e successivo alla frana.


![image](https://github.com/user-attachments/assets/34b45dbb-6912-4c2b-924f-9135dd4f9c52)
>*La zona presa in considerazione, Lötschental, distretto di Raron Occidentale*


## Acquisizione delle immagini satellitari 🛰️📡
### Download immagini ⬇️
Attraverso [Google Earth Engine](https://earthengine.google.com) ho scaricato le immagini satellitari provenienti dalla missione ESA Sentinel-2.

Per l'area di studio sono state scelte due immagini, nello specifico:
+ per la prima, il periodo preso in consideravione va dal **01/05** al **25/05**, il mese precedente alla frana; 
+ per la seconda, il periodo preso in consideravione va dal **30/05** al **30/06**, il mese successivo alla frana.

Ecco di seguito il codice in JavaScript utilizzato su [Google Earth Engine](https://earthengine.google.com):

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

Le immagini restituite sono la mediana composita delle immagini relative al periodo indicato, un filtro ulteriore è stato applicato sciegliendo solo quelle la cui copertura nuvolosa è inferiore al 20%.

### Importazione immagini su R e visualizzazione 💻

Sono stati utilizzati i seguenti pacchetti per importazione, visualizzazione eanalisi delle immagini:
+ ***terra***, pacchetto per importare immagini e altre funzioni enunciate succesivamente;
+ ***imageRy***, per la visualizzazione, analisi delle immagini e altre funzioni;
+ ***viridis***, serve per palette di colori;
+ ***ggridges***, per craere plot ridgeline;
+ ***ggplot2***, creazione di grafici a barre; 
+ ***patchwork***, unione dei grafici creati con ggplot2.


Dopo aver scaricato le immagini su google drive in formato .tif,  eseguo il download salvandole nella cartella apposita sul mio dispositivo.

Per prima cosa imposto la directory di lavoro
```R
setwd("/Users/lucagrazia/Downloads") #imposto la working directory
```

Importazione delle immagini su R attraverso la funzione rast() e visualizzazione con i colori reali im.plotRGB() impostando un pannello multiframe per mostrarle entrambe.
```R
blattenpre=rast("blattenpre1.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino
blattenpost=rast("blattenpostNIR.tif") #importo il raster attraverso la funzione rast() di terra e lo nomino

png("blattenrgb.png") #funzione che mi permette di salvare una copia dell'immagine in formato.png
im.multiframe(1,2) #con questa funzione di imageRy apro un pannello multiframe che mi permette di vedere le 2 immagini una affiancate (una linea, due colonne) 
plotRGB(blattenpre, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Prima") #funzione plot RGB di imageRy per visualizzare l'immagine nello spettro del visibile, Stretch lineare: i valori vengono riscalati linearmente tra 0 e 255 per visualizzare meglio l'immagine.
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten Dopo")
dev.off()
```
![blattenrgb](https://github.com/user-attachments/assets/5669853d-edd2-436e-9838-2235a0a0161d)
>*Le due immagini che mostrano le differenze tra prima e dopo la frana*

Isolo e confronto le due immagini mettendo in risalto solo le corrispettive bande Near Infra-Red 

```R
png("blattenbandaNIR.png")
im.multiframe(1,2) 
plot(blattenpre[[4]], stretch="lin", main = "BlattenpreNIR", col=inferno(100)) #attraverso viridis utilizza la palette di colori "inferno" specificando il numero di colori che voglio nella scala per uniformarlo alla seconda immagine
plot(blattenpost[[4]], stretch="lin", main = "BlattenpostNIR", col=inferno(100))
dev.off()
```
![blattenbandaNIR](https://github.com/user-attachments/assets/431a9903-7ebe-4a69-8f13-bc3b2af8d05c)
>*si può intravedere una massa nel centro dell'immagine che corrisponde alla frana*

Visualizzo quindi il suolo nudo ponendo la banda **NIR**, al posto della banda blu mostrando così la vegetazione di quest'ultimo colore mentre tutto quello che non è vegetazione viene mostrato nella scala del giallo, solitamente è usato per evidenziare il suolo nudo
```R
png("blattensuolonudo.png")
im.multiframe(1,2)
plotRGB(blattenpre, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Prima") #imposto il NIR sulla banda Blu
plotRGB(blattenpost, r = 1, g = 2, b = 4, stretch="lin", main = "Blatten Dopo")
dev.off()
```
![blattensuolonudo](https://github.com/user-attachments/assets/23d8fe19-198b-4b20-93fd-b61debeef27b)
>*Il colore blu è aumentato nella seconda immagine dato l'aumento delle temperature e il conseguente scioglimento della massa nevosa, si nota chiaramente la frana*

## Analisi immagini 🔎
### Indici spettrali
##### DIFFERENT VEGETATION INDEX - DVI 🌲
**Calcolo: DVI= NIR - red**

Questo indice restituisce informazioni dettagliate sullo stato di salute delle piante attraverso la riflettanza della vegetazione nelle bande del rosso e NIR. In caso di stress le cellule a palizzata diminuiscono la loro capacità fotosintetica per ridurre la perdita d'acqua, per cui la riflettanza nel NIR sarà più bassa.
```R
DVIpre=im.dvi(blattenpre, 4, 1) #funzione im.dvi di imageRy che prende l'immagine da analizzare e automaticamente il dvi sottraendo dala banda NIR la banda del RED
plot(DVIpre, col=inferno(100)) #uso inferno di viridis
dev.off()

DVIpost=im.dvi(blattenpost, 4, 1) #funzione im.dvi di imageRy che prende l'immagine da analizzare e automaticamente il dvi sottraendo dala banda NIR la banda del RED
plot(DVIpost, col=inferno(100))  #uso inferno di viridis
dev.off()

png("blattenDVI.png")
im.multiframe(1,2) #Creo un pannello multiframe per confrontare le immagini su cui è stato calcolalto il DVI
plot(DVIpre, stretch = "lin", main = "pre_frana", col=inferno(100))
plot(DVIpost, stretch = "lin", main = "post_frana", col=inferno(100))
dev.off()
```
![blattenDVI](https://github.com/user-attachments/assets/eeed0cf9-7636-49d7-afbd-700a490742d5)
>*In queste imamigni si può percepire la distribuzione della biomassa vegetale (visibile in giallo) che si estende nella valle, la differenza principale sorge nella seconda immagine dove c'è un chiaro segno della massa inerte rappresentata da un'area più scura nel centro*

#### NORMALIZED DIFFERENCE VEGETATION INDEX - NDVI 🌲
**Calcolo: NDVI= (NIR - red) / (NIR + red)**

L'NDVI è un indice spettrale usato per misurare la “vigoria” o lo stato di salute della vegetazione, i valori restituiti vengono normalizzati tra -1 e +1 (calcolando la somma NIR + red).
In questo caso si può verificare la presenza della vegetazione nelle immagini che sono per verificare l'impatto della frana.

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
>*Nella prima imamgine si può apprezzare come la vegetazione del fondovalle sia sana e abbia una buona copertura nonostante la presenza cospicua di neve, mostrando comunque vaolori vicini a 0.8; nella seconda immagine rimane sempre una vegetazione florida, con presenza di valori anche più alti, ma si distingue più chiaramente la frana*

#### NORMALIZED DIFFERENCE WATER INDEX 🚰
**NDWI= (Green-NIR)/(Green+NIR)**

Indice spettrale usato per identificare l'acqua superficiale nelle immagini satellitari (McFeeters, 1996).
Questa formula fa risaltare l’acqua **(valori positivi)** e scurisce la vegetazione e il suolo (valori negativi).

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
Osservando il funzionamento della funzione im.ndvi(), ho notato una certa somiglianza al calcolo dell'indice NDWI, ho cercato quindi di cambiare i parametri presenti per creare una funzione che potesse restituirmi NDWI velocemente

``` R
#imposto la funzione 
im.ndwi <- function(x, green, nir){
  
  if(!inherits(x, "SpatRaster")) {                                    #se non è SpatRaster si ferma
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(green, "numeric") && !inherits(nir, "numeric")) {
    stop("green and NIR layers should be indicated with a number")   #se verde e nir non non sono associati ad un numero si ferma
  }
  
  ndwi = (x[[green]] - x[[nir]]) / (x[[green]] + x[[nir]])           #scrivo funzione di McFeeters
 
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

>*In giallo si può notare un accumulo di acqua del torrente Lonza a monte della frana dovuto allo sbarramento della massa rocciosa*

### Analisi Multitemporale 🕙
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
>*È visibile una zona di colore diverso nel centro dell'immagine, nello specifico nella seconda immagine, che corrisponde alla frana*

Applico la funzione **draw del pacchetto terra** per selezionare un'area specifica dell'immagine, questo è importante perchè, in questo caso, lo scioglimento rapido della neve tra meggio e giugno ha portato ad una vigoria maggiore delle piante, per cui ho scelto un'area più piccola per analizzare più efficaciemente.

```R
#funzione draw di terra
plotRGB(blattenpost, r = 1, g = 2, b = 3, stretch = "lin", main = "Blatten_POST (RGB)")
crop_blatten = draw(x="extent", col="red", lwd=2) #rettangolo, rosso, di spessore 2 creato sull'immagine
blatten_post_crop = crop(blattenpost, crop_blatten) #blattenpost croppata
blatten_pre_crop = crop(blattenpre, crop_blatten) #blattenpre croppata

blatten_ndvi_pre_crop = crop(NDVIprima, crop_blatten) #ndvi precedente croppato 
blatten_ndvi_post_crop = crop(NDVIdopo, crop_blatten) #ndvi successivo croppato

png("blattencrop.png")
im.multiframe(2,2) # creo multiframe con le aree croppate e l'NDVI
plotRGB(blatten_pre_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "maggio")
plotRGB(blatten_post_crop, r = 1, g = 2, b = 3, stretch = "lin", main = "giugno")
plot(blatten_ndvi_pre_crop, main = "NDVI maggio")
plot(blatten_ndvi_post_crop, main = "NDVI giugno")
dev.off()
```
![blattencrop](https://github.com/user-attachments/assets/271554fb-c7dd-4369-be99-73942de5aed7)
>*Le aree croppate e le corrispettive con indice NDVI*

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
+ **NDVI di giugno** mostra un aumento dei valori di NDVI basso (si nota anche la presenza dello speccio d'acqua dai colori NDVI molto bassi) causati dalla presenza del materiale inerte portato dalla frana, mostra inoltre un aumento dei valori di NDVI alto dato che la vegetazione è in piena attività fotosintetica


### Classificazione delle immaigni 📊

Visualizzare la variazione percentuale di NDVI nel sito, prima suddivido i pixel in due classi e poi, tramite un grafico a barre del pacchetto ggplot2, mostro la variazione.
```R
blatten_maggio_classi = im.classify(blatten_ndvi_pre_crop, num_clusters=2)   # divido i pixel di ogni immagine in due cluster per capire come sono stati classificati  
blatten_giugno_classi = im.classify(blatten_ndvi_post_crop, num_clusters=2)

png("visualizzazione_classi_ndvi1.png")
im.multiframe(2,2) #plotto le due immagini in cui risaltano i due cluster di pixel e la corrispettiva diffrerenza
plot(blatten_maggio_classi, main = "Pixel prima della frana")
plot(blatten_giugno_classi, main = "Pixel dopo la frana")
plot(blatten_maggio_classi - blatten_giugno_classi, main = "Differenza Pixel NDVI blatten\n(maggio-giugno)")
dev.off()
```
![visualizzazione_classi_ndvi1](https://github.com/user-attachments/assets/857f3ab1-554c-47ab-ba6f-1bd20dcff57f)
>*Immagine che mostra le classi in cui sono stati divisi i pixel e la corrispettiva differenza dove, in viola, viene evidenziata la frana rispetto al territorio sottostante*

Valori delle classi:
+ 1 valori **elevati** di NDVI -> vegetazione
+ 2 valori **bassi** di NDVI -> roccia, neve, sassi,...

Il colore viola mostra la differenza sostanziale tra le due immagini evidenziando l'area colpita

Trovo le percentuali di copertura di ciascuna classe di pixel relativi alle due immagini, per farlo calcolo la frequenza attraverso la funzione freq() di **R** per trovare il numero di celle (pixel) di ciascun valore.
Successivamente trovo il numero di pixel totali con la funzione ncell() di **R**.
Applico una divisione, trovo le percentuali e produco un dataframe.
```R
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

```

Attraverso la funzione ggplot che è funzione di base per fare i plot grafici, li sviluppo e poi unisco i grafici:
```R
ggplotmaggio1 = ggplot(tabout, aes(x=NDVI, y=maggio, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))
ggplotgiugno1 = ggplot(tabout, aes(x=NDVI, y=giugno, fill=NDVI, color=NDVI)) + geom_bar(stat="identity") + ylim(c(0,100))

png("ggplot1.png") 
ggplotmaggio1 + ggplotgiugno1
+ plot_annotation(title = "Valori NDVI (espressi in superficie) nell'area di Blatten")    # creo un plot con i due grafici, plot annotation mi serve per aggiungere un titolo
dev.off()
```
![ggplot1](https://github.com/user-attachments/assets/98c1bde2-15d3-4f3f-ad3b-a08d1865a10b)
>*In questo grafico si può vedere come, nonostante lo scioglimento della neve, abbia portato ad un incremento della vegetazione facendo aumetare i valori alti di NDVI, i valori bassi siano comunque aumentati a seguito della frana*


## Conclusioni ✍️📖
Valori DVI e NDVI, aggiungo alla fine NDWI

+ frana
+ lago e problema in inverno con piogge forti 
+ altre info

proposta monitoraggio a lungo termine per impatto alla vegetazione, lago formato
