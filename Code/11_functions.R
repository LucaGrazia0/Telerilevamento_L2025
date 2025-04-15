#code to build yur own function
#facciamo una somma, x e y osno i numeri che utente assegnerà 

somma <- function(x,y) {
  z=x+y
  return(z)
  }

diff <- function(x,y) {
  z=x-y
  return(z)
  }


#scrivo una funzione che scriva cose al posto mio, tipo multiframe

mf <- function(nrow,ncol) {
  par(mfrow=c(nrow,ncol))
  }

#funzioni per sapere se sono numeri positivi o negaticvi con if else

positivo <- function(x) {
  if(x>0) {
    print("cojone è positivo")
  }
  else if (x<0) {
    print("dai mona è negativo")
  }
  else{
    print("lo zero è zero")
  }
  }
