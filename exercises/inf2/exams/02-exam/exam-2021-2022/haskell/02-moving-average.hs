-- а). “Пълзяща средна стойност” (“moving average”) на редица от дробни числа S с прозорец n наричаме
-- редицата от средни аритметични на n последователни елемента от S, където n е предварително фиксирано цяло число.
-- Да се реализира функция movingAverage, която по даден безкраен поток от дробни числа S и естествено число n ≥ 2
-- връща безкрайния поток от пълзящата средна стойност на S с прозорец n

take' 0 _  = []
take' _ [] = []
take' n (x:xs) = x : take' (n - 1) xs

movingAverage stream n =
  average (take n stream) : movingAverage (tail stream) n
  where average lst = sum lst / fromIntegral (length lst) 
  -- налага се да ползваме fromIntegral тук, защото типа на резултата на length e цяло число
  -- length :: Foldable t => t a -> Int
  -- и haskell се кара, че типовете ни не съвпадат

-- този поток не знам как е бил генериран, затова по-долу fake-вам мой си поток
-- с тестови цели като заляпям редицата от естествени числа след списъка от подадени числа
-- movingAverage [1076,1356,1918,6252,6766,5525, … ] 3
-- => [1450.0,3175.3,4978.6,6181.0, …]

-- stream = [1076.0, 1356, 1918, 6252, 6766, 5525] ++ [0..]
-- take' 4 (movingAverage stream 3) -- => [1450.0, 3175.3333333333335, 4978.666666666667, 6181.0]

-- б). Да се реализира функция allAverages, която по даден безкраен поток от дробни числа S
-- връща безкраен поток от безкрайни потоци A2, A3, A4,... където An представлява
-- пълзящата средна стойност на S с прозорец n

allAverages stream =
  map (\n -> movingAverage stream n) [2..]

-- този поток не знам как е бил генериран, затова по-горе fake-вам мой си поток
-- с тестови цели като заляпям редицата от естествени числа след списъка от подадени числа
-- allAverages [1076, 1356, 1918, 6252, 6766, 5525, … ]
-- => [[1216.0,1637.0,4085.0,6509.0, …], [1450.0, 3175.3,4978.6,6181.0, …], [2650.5,4073.0,5115.25, … ], …]

-- take' 3 (map (\stream -> take' 4 stream) (allAverages stream))
-- => [[1216.0, 1637.0, 4085.0, 6509.0],
--     [1450.0, 3175.3333333333335, 4978.666666666667, 6181.0],
--     [2650.5,4073.0,5115.25,4635.75]]