library(PogromcyDanych)
library(stringr)
data(auta2012)

# 1.Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?
auta2012 %>%
  filter(Waluta == "PLN" & Rodzaj.paliwa == "naped elektryczny") %>%
  summarise(median_cost = median(Cena.w.PLN, na.rm = TRUE))
  
  
  
# Odp: 18900

# 2.W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
  # roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
  # mechanicznych (KM) jest najwi�ksza.
auta2012 %>% 
  select(KM, Marka, Rok.produkcji) %>% 
  mutate(date = ifelse(Rok.produkcji >= 2001, "new", "old")) %>% 
  select(Marka, KM, date) %>% 
  summarise(median_km = median(KM, na.rm = TRUE), .by = c("Marka", "date")) %>% 
  top_n(1,median_km)
  



# Odp: Bugatti po 2001 roku



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
auta2012 %>% 
  filter(Kolor == "szary-metallic" &
           Cena.w.PLN > min(median(Cena.w.PLN, na.rm = TRUE),mean(Cena.w.PLN,na.rm = TRUE)) &
           Cena.w.PLN < max(median(Cena.w.PLN,na.rm = TRUE),mean(Cena.w.PLN,na.rm = TRUE))) %>%
  filter(as.character(Kraj.pochodzenia) != as.character(Kraj.aktualnej.rejestracji)) %>%
  summarise(n = n())

  



# Odp: 1849



# 4. Jaki jest rozstęp międzykwartylowy przebiegu (w kilometrach) Passatów
# w wersji B6 i z benzyną jako rodzajem paliwa?

auta2012 %>% 
  filter(Model == "Passat", Rodzaj.paliwa == "benzyna", Wersja == "B6") %>% 
  #IQR to funkcja odpowiadaj�ca za znalezienie odst�pu mni�dzykwartylowego
  summarise(odstep = IQR(Przebieg.w.km, na.rm = TRUE))


# Odp: 75977.5



# 5. Biorąc pod uwagę samochody, których cena jest podana w koronach czeskich,
# podaj średnią z ich ceny brutto.
# Uwaga: Jeśli cena jest podana netto, należy dokonać konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(po.podatku = if_else(Brutto.netto == "netto", Cena*1.02, Cena)) %>% 
  summarise(srednia = mean(po.podatku))


# Odp:210678.3



# 6. Których Chevroletów z przebiegiem większym niż 50 000 jest więcej: tych
# ze skrzynią manualną czy automatyczną? Dodatkowo, podaj model, który najczęściej
# pojawia się w obu przypadkach.

auta2012 %>% 
  filter(Marka == "Chevrolet" & Przebieg.w.km > 50000) %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(n=n())
# wi�cej jest samochod�w z manualn� skrzyni� bieg�w

auta2012 %>% 
  filter(Marka == "Chevrolet" & Przebieg.w.km > 50000 & Skrzynia.biegow == "manualna") %>% 
  group_by(Model) %>% 
  summarise(n=n()) %>% 
  top_n(1,n)
# Z manualna by�o wi�cej Lancetti

auta2012 %>% 
  filter(Marka == "Chevrolet" & Przebieg.w.km > 50000 & Skrzynia.biegow == "automatyczna") %>% 
  group_by(Model) %>% 
  summarise(n=n()) %>% 
  top_n(1,n)
# Z automatyczna bylo wiecej Corvette

# Odp:Wiecej jest aut z manualn�. Z manualn� bylo najwiecej Lancetti. 
# z automatyczna bylo wiecej Corvette




# 7. Jak zmieniła się mediana pojemności skokowej samochodów marki Mercedes-Benz,
# jeśli weźmiemy pod uwagę te, które wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  filter(Marka == "Mercedes-Benz") %>% 
  mutate(czy.przed = ifelse(Rok.produkcji >= 2003, 1, 0)) %>% 
  #podobny efekt mozna otrzyac za pomoca funkcji as.logical
  summarise(mediana = median(Pojemnosc.skokowa, na.rm = TRUE, ),.by = czy.przed)


# Odp: Mediana pojemnosci skokowej przed i po 2003 jest taka sama 



# 8. Jaki jest największy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodzących z Niemiec?

auta2012 %>% 
  filter(Kraj.aktualnej.rejestracji == "Polska" & Kraj.pochodzenia == "Niemcy") %>% 
  select(Przebieg.w.km) %>% 
  arrange(-Przebieg.w.km) %>% 
  top_n(1,Przebieg.w.km)


# Odp:1e+09



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodzących z Włoch?

auta2012 %>% 
  filter(Marka == "Mitsubishi" & Kraj.pochodzenia == "Wlochy") %>%
  summarise(ilosc = n(), .by = Kolor) %>% 
  arrange(ilosc) 


# Odp: Drugi najmniej popularny kolor to granatowy-metalic



# 10. Jaka jest wartość kwantyla 0.25 oraz 0.75 pojemności skokowej dla 
# samochodów marki Volkswagen w zależności od tego, czy w ich wyposażeniu 
# dodatkowym znajdują się elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen") %>% 
  mutate(el.lusterka = str_detect(Wyposazenie.dodatkowe, "el. lusterka")) %>% 
  # funkcja str_detect pozwala nam na znalezienie konkretnej informacji ze stringa
  # zwraca wartosc TRUE lub FALSE
  group_by(el.lusterka) %>% 
  summarise(kwant. = quantile(Pojemnosc.skokowa, probs = c(0.25, 0.75), na.rm = TRUE)) %>% 
  View()

# Odp:kwantyle to odpowiednio: bez lusterek - 1400 i 1900
# natomiast z elektrycznymi lusterkami 1892.25, 1968.00


