# Implementacja instancji klasy Random dla typu For

## Ogólna zasada działania

Aby wybrać losową formułę KRZ `f` o zadanej długości `len` i liczbie różnych zmiennych `k`, należy wpisać:

```hs
(f, g') = randomR (V len, V k) g
```

Gdzie `g` jest stanem generatora liczb losowych (typu `RandomGen`), a `g'` jego nowym stanem zwróconym po dokonaniu losowań.

Aby wybrać potencjalnie nieskończony ciąg formuł `fs`, można napisać:

```hs
fs = randomRs (V len, V k) g
```

`V len` i `V k` są wartościami typu `For` opisującymi zmienne o numerach `len` i `k`. Wynika to z tego, że klasa `Random` narzuca, by argumenty dla funkcji `randomR` opisujące pożądany przedział były parą wartości losowanego przez nią typu.

## Przyjęte konwencje

* Zmienna o nazwie `len` każdorazowo oznacza długość formuły.
* Zmienne o nazwach `n` i `k`, używane w funkcjach kombinatorycznych, odpowiadają ich standardowemu znaczeniu w literaturze. W konsekwencji w kontekście pakietu zazwyczaj oznaczają więc liczba instancji/wystąpień zmiennych (`n`) i (`k`) liczba różnych zmiennych w formule.
* `f` zawsze oznacza formułę, a `fs` ich ciąg.
* Zmienne zaczynające się na `g` są stanami generatora liczb pseudolosowych, przy czym `g'`, w miarę możliwości, jest ostatnim stanem w funkcji i zostaje przez nią zwrócony.
* Funkcje kończące się na `Det` dotyczą formuł KRZ o doprecyzowanej liczbie wystąpień zmiennych (`n`).
* Funkcje kończące się na `Arb` dotyczą formuł o sprecyzowanych jedynie długości i liczbie różnych zmiennych.
* Funkcje `Det` i `Arb` _nie zliczają ani nie generują_ formuł zawierających `Verum`, ponieważ nie odróżniają one od siebie operatorów zero-argumentowych i do ich reprezentacji posiłkują się jedynie wartością `V 0`.
* Implementacja traktuje operatory ze wszystkimi argumentami ustawionymi na `Verum` oraz zmienne `V 0` do reprezentowania samych węzłów jako takich (przed zbudowaniem formuły) i w takiej formie są one pierwotnie losowane oraz przekształcane aż do ostatecznego utworzenia formuły wyjściowej.

## Struktura implementacji
Kod otwiera deklaracja instancji klasy `Random`, jest to jedyna część kodu przewidziana do użytku "zewnętrznego", ponieważ tylko ona generuje funkcje zawierające `Verum`.

Funkcje takie jak `generateArb` oraz `generateDet` również mogą być używane do zrównoważonego generowania formuł, jednak zwracają one formuły bez stałych. Takie przeniesienie ciężaru wstawiania funkcji `Verum` na sam koniec procesu ma na celu uniknięcie zbędnego spowolnienia pracy algorytmu.

## Funkcje instancji `Random For`

### `random :: RandomGen g => g -> (For, g) `

Zwraca losowy operator w postaci opisanej ostatnim podpunktem z listy przyjętych konwencji oraz nowy stan generatora liczb pseudolosowych. Istnieje przede wszystkim dla spełnienia wymogów stawianych przez klasę typów `Random`.

### `randomR :: RandomGen g => (For, For) -> g -> (For, g) `

Zasadnicza funkcja instancji. Oczekuje pierwszego argumentu w postaci `(V len, V k)`, gdzie `len` jest wymaganą długością formuły a `k` liczbą różnych zmiennych.

Zwraca formułę odpowiadającą podanym wymogom oraz nowy stan generatora liczb pseudolosowych.

Jeśli argumenty nie odpowiadają wzorcowi `(V len, V k)`, funkcja zachowuje się tak samo jak `random`.

## Opisy funkcji

### `factorial :: Int -> Int`

Oblicza `n!`.

Zapamiętuje wszystkie obliczone wcześniej wartości.

### `stirling :: Int -> Int -> Int`

Oblicza liczbę podziałów zbioru n-elementowego na k rozdzielnych
podzbiorów.

Zapamiętuje wszystkie obliczone wcześniej wartości.

### `rotate :: Int -> [a] -> [a]`

Tworzy ciąg `uw` taki, że `xs == wu` i `length w == n`

### `arity :: For -> Int`

Zwraca arność głównego spójnika formuły `x`. Wszystkie argumenty
tego spójnika muszą być równe `Verum`. W przypadku zmiennej, jej numer musi być równy 0.

### `countDet :: Int -> Int -> Int -> Int`

Zwraca liczbę formuł o sprecyzowanej długości `len`,
liczbie instancji zmiennych `n` oraz liczbie różnych zmiennych `k`.

### `countArb :: Int -> Int -> [Int]`

Oblicza liczbę możliwych formuł o sprecyzowanej długości `len`
oraz liczbie różnych zmiennych `k`. Zwrócony wynik jest w postaci ciągu
wyników cząstkowych takich, że na `n`-tej pozycji jest liczba formuł
o `k+n` instancjach zmiennych.

### `prefixLength :: [For] -> Int`

Dla ciągu formuł `fs` oblicza długość jego prefiksu, po którego
przerotowaniu powstanie ciąg formuł odpowiadający poprawnej formule
zapisanej w notacji Łukasiewicza.

### `randomSamples :: RandomGen g => [a] -> Int -> g -> ([a], g)`

Tworzy ciąg długości `n` powstały z losowo wybranych elementów `list`.
Wybory losowe mogą się powtarzać. Zwrócona zostaje para tak powstałego ciągu
z nowym stanem generatora liczb pseudolosowych.

### `weightedChoice :: RandomGen g => [(Int, a)] -> g -> (a, g)`

Przyjmuje ciąg par wag z pewnymi wartościami. Zwrócona zostaje jedna losowo
wybrana z tych wartości, przy czym szanse jej wylosowania są równe stosunkowi
przypisanej wagi do sumy wszystkich wag w wejściowym ciągu. Funkcja zwraca
parę wybranego elementu z nowym stanem generatora liczb pseudolosowych.

### `nameVars :: [Int] -> [For] -> [For]`

Funkcja przyjmuje ciąg liczbowy oraz _ciąg_ formuł, następnie przypisuje
występującym w nim węzłom wartości z ciągu liczbowego zachowując przy tym ich
kolejność.

### `varToVerum :: Int -> For -> For`

Tworzy i zwraca formułę o zmiennej `n` przemianowanej na `Verum`, wyższe
numery zmiennych zostają zdekrementowane.

### `buildFor :: [For] -> (For, [For])`

Przyjmuje ciąg formuł odpowiadający poprawnej formule zapisanej
w notacji Łukasiewicza i zwraca odpowiadającą mu formułę oraz "resztę",
która w przypadku głównego (nierekurencyjnego) wywołania funkcji powinna być
zwrócona jako pusta lista.

### `generateRGF :: RandomGen g => Int -> Int -> g -> ([Int], g)`

Funkcja zwraca losowo wybraną funkcję RGF o długości `n`
i maksymalnej wartości `k-1`.

### `generateDet :: RandomGen g => Int -> Int -> Int -> g -> (For, g)`

Zwraca losowo wybraną formułę o sprecyzowanej długości `len`,
liczbie instancji zmiennych `n` oraz liczbie różnych zmiennych `k`.

### `generateArb :: RandomGen g => Int -> Int -> g -> (For, g)`

Zwraca losowo wybraną formułę o sprecyzowanej długości `len`,
oraz liczbie różnych zmiennych `k`.

## Słowny opis algorytmu używanego w `randomR`

i kilka uzasadnień.

1. Dla danej długości i liczby zmiennych obliczona zostaje liczba formuł nie posiadających funkcji `Verum` oraz liczba formuł ją posiadających (`(k+1) * (sum $ countArb len (k+1))`).
	* Wzór ten wyprowadzić można z wyobrażenia formuł zawierających `Verum` jako formuł o dodatkowej `(k+1)`-szej zmiennej, a później wybrania losowej ze zmiennych (na jeden z (k+1) sposobów) i przekształcenia jej w explicite `Verum`. Dla zachowania numerowania zmiennych zgodnych z definicją RGF, numery zmiennych wyższych od przekszałconej zostają zdekrementowane.
	* Można pokazać, że nie istnieją dwie różne ścieżki losowych decyzji prowadzące od dwóch różnych formuł z `k+1` zmiennymi do takiej samej formuły zawierającej funkcje `Verum`. W tym celu załóżmy stwierdzenie odwrotne. Mamy więc pewne dwie identyczne formuły zawierające `Verum`, w których ponadto występują jakieś zmienne ponumerowane zgodne z wybraną losowo funkcją RGF. Zmianie w omawianym przekszałceniu uległy jedynie numery zmiennych oraz węzły `Verum`. Spójrzmy więc na pierwszą funkcję `Verum` występującą w obu formułach. W obu przypadkach przed ostatnim krokiem algorytmu generującego była w ich miejscu pewna zmienna o numerze nie występującym wcześniej w formule (zgodnie z budową funkcji RGF), a ponieważ założenie jest takie, że obie formuły obecnie się nie różnią, to w obu przypadkach wszystkie poprzedzające ją zmienne mają takie same numery. Z tego, oraz definicji RGF, wynika, że zmienne, które zamieniono na `Verum` także miały w obu formułach ten sam numer, a dokładnie: o jeden wyższy od najwyżej ponumerowanej występującej przed nimi zmiennej. Ponadto numery zmiennych wyższe od numeru zmiennej przemianowanej zostały zdekrementowane, przed dekrementacją miały więc one ten sam rozkład i numery w obu formułach wejściowych. Obie formuły były przed ostatnim krokiem algorytmu takie same.
2. Zostaje wylosowana wartość `choice` taka, że `1 <= choice <= |formuły z Verum|+|formuły bez Verum|`, jeśli jest ona większa od liczby formuł bez `Verum`, wtedy losowana jest formuła bez `Verum` funkcją `generateArb`, w przeciwnym wypadku (również z użyciem `generateArb`) losowana jest formuła o dodatkowej zmiennej, w której później zmienna o losowo wybranym numerze zostaje przemianowana na `Verum` (zgodnie z działaniem funkcji `varToVerum` opisanej też słownie w pierwszym podpunkcie punku 1).
3. Następnie (w funkcji `generateArb`) doprecyzowana zostaje kolejna wartość: `n` (liczba wystąpień zmiennych w formule). Dla każdego możliwego `n` (tj. z zakresu od `k` wzwyż). Każdej z wartości `n` przypisana zostaje waga odpowiadająca liczbie formuł możliwych do zbudowania przy `n` miejscach zarezerwowanych dla instancji zmiennych. Ostateczna wartość zostaje wybrana za pomocą losowania z wagami (`weightedChoice`).
4. Z wybranym już `n` uruchomiona zostaje funkcja `generateDet` wybierająca losowe operatory binarne, losowe operatory unarne, oraz nieponumerowane zmienne (wszystkie jako `V 0`). Liczba każdej z powyższych jest zdeterminowana prez ustalone już parametry `len`, `n` i `k`. Następnie na takim ciągu operatorów wykonywany jest algorytm wyboru losowej składni opisany przeze mnie na seminarium w dniu 31.05.2019.
5. Zmienne tak powstałej formuły zostają ponumerowane (funkcja `nameVars`) wartościami funkcji RGF losowo wybranej dla danego `n` i `k` (funkcja `generateRGF`).
	* działanie `generateRGF` opiera się na nieco przekształconym algorytmie z książki N. Loehra "Bijective Combinatorics" - przykład 5.43, strona 204, który zakładał użycie losowej liczby rzeczywistej.
6. Tak powstała formuła jest jeszcze reprezentowana ciągiem operatorów w notacji Łukasiewicza, zostaje to naprawione funkcją `buildFor`, która składa ją w pełnoprawny obiekt typu `For`.
