-- cover all cases!
{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}
-- no incomplete patterns in lambdas!
{-# OPTIONS_GHC -fwarn-incomplete-uni-patterns #-}
-- use different names!
{-# OPTIONS_GHC -fwarn-name-shadowing #-}
-- use all your pattern matches!
{-# OPTIONS_GHC -fwarn-unused-matches #-}

import Prelude hiding (Either (..), Maybe (..), length)

-- TODO Throbwack - Мързеливо оценяване:
----------------------------------------

-- Типови класове:
------------------
-- Ако погледнем някоя полиморфична функция:
length :: [a] -> Int
length [] = 0
length (_ : xs) = 1 + length xs

-- ще видим че тя не се интересува от елементите на списъка.
-- (дори не се оценяват, заради мързеливото оценяване на Haskell)

-- Ето една имплементация на quicksort за числа
quicksort :: [Int] -> [Int]
quicksort [] = []
quicksort (x : xs) = quicksort lower ++ [x] ++ quicksort higher
  where
    lower = [y | y <- xs, y <= x]
    higher = [y | y <- xs, y > x]

-- Какво обаче ако искаме да я направим полиморфична?

-- Ако пробваме да сменим Int с a, веднага ще получим компилационна грешка,
-- която ще ни подскаже за следната декларация:
-- quicksort :: Ord a => [a] -> [a]

-- "Ord a =>" декларира че елементите от типа "a" можем да ги сравняваме.
-- Това се нарича се class constraint (класово ограничение).
-- Тук имаме различен тип полиморфизъм (ad-hoc)

-- Ord е типов клас (НЕ клас като тези в ООП)

-- Може да си мислите за типовите калсове като: множества/предикати/интерфейси

-- Числата са полиморфични константи.

-- Алгебрични Типове:
---------------------
-- С ключовата дума data можем да дефинираме алгебричен тип данни (ADT).
-- Алгебричен, защото се дефинира чрез "алгебрични" операции:

-- "Сума"
-- Това е нещо което би се постигнало с "enum" в други езици.
data Color
  = Red
  | Green
  | Blue
  deriving (Show) -- Show е типов клас, чийто елементи могат да се принтират.
  -- Този ред казва на Haskell да генерира нужните имплементации за Show.

-- "Произведение"
data Point = Point Int Int Int
  deriving (Show)

-- Нещо изглежда ли странно в тази дефиниция? (TODO: да ползваме Mk конвенция?)

-- Колко възможни стойности има от тип Color и Point?

-- Конструктори:
----------------
-- Това което прави data е:
-- Въвежда типов конструктор и конструктори на данни
-- за съответния типов конструктор. Какво означава това?
--
-- 1) конструктор на типове - функция над типове
-- 2) конструктор на данни - (специална) функция над стойности

-- Дефиницията на списъците в Prelude, която ви бях дал:
-- 1) [] - празния списък
-- 2) x : xs - елемент x залепен за списък xs
--  * Важно е че ако x :: a, то xs :: [a]

-- Кои са конструктори на типове и кои са конструктори на данни?
-- TODO: type and kind
data List a
  = Nil
  | Cons a (List a)
  deriving (Show)

-- Конструкторите могат да се прилагат частично.

-- Като дефинирахме залепянето на елемент към списък префиксно,
-- започва да прилича на scheme:
someList :: List Int
someList = Cons 1 (Cons 2 (Cons 3 Nil))

-- А всъщност списъка в Prelude е дефиниран така:
-- data a [] = [] | a : [a]

-- Още типове:
--------------
-- Какво правят и как може да са ни полезни?

-- Maybe:
data Maybe a
  = Nothing
  | Just a
  deriving (Show)

-- Either:
data Either a b
  = Left a
  | Right b
  deriving (Show)

-- Двоично дърво:
data BTree a
  = Leaf
  | Node a (BTree a) (BTree a)
  deriving (Show)

-- Да пробваме да декларираме граф:
-- Всеки връх в графа има стойност и съседи.
-- (TODO: съседите трябва ли да са върхове?)
data GNode a = GNode
  { value :: a,
    adjacents :: [a]
  }

-- Използваме record syntax, за да дадем имена на "полетата".
-- Освен това, сега Haskell ни генерира функции със същите имена,
-- с които можем да селектират съответните стойности:

-- >>> value (GNode 5 [])
-- 5

-- Съответно целият граф ще е списък от върховете:
data Graph1 a = Graph1 [GNode a]

-- Тук се вижда как само слагаме обвивка на вече съществуващ тип - [GNode a].
-- Има синтаксис (newtype) за този специален случай:
newtype Graph2 a = Graph2 [GNode a]

-- Или може просто да направим синоним на [GNode a]
type Graph a = [GNode a]

-- Помните ли тази дефиниция на факториел и как зацикля за отрицателни числа?
fact :: Int -> Int
fact 0 = 1
fact n = n * fact (n - 1)

-- Можем да избегнем това по 2 начина:
-- 1) Да правим проверка/преобразувание така че функцията да работи
--    за всички стойности от тип Int (т.е. правим по-силна имплементация)
-- 2) Да направим типа по-силен - вместо Int да ползваме естествени числа

data Nat -- от Natural number (естествено число)
  = Zero
  | Succ Nat
  deriving (Show)

-- TODO parse don't validate

-- Pattern matching ADTs:
-------------------------
-- Вече видяхме как можем да pattern match-ваме по (:)
-- >>> :t (:)
-- (:) :: a -> [a] -> [a]
-- То е някаква функция, какво й е специалното?
-- Защо не можем да правим pattern matching по (++) примерно?

-- Можем да pattern match-ваме по конструкторите на ADT
mapList :: (a -> b) -> List a -> List b
mapList _ Nil = Nil
mapList f (Cons h t) = Cons (f h) (mapList f t)

-- Може да си мислим за имената на конструкторите
-- като тагове които стоят пред стойностите,
-- immutable низове, които съпоставяме като литерали (константи).

--------------------------------------------------------------------------------
-- ЗАДАЧИ --
------------

-- За дадено n връща (n - 1)
--
-- Примери:
-- >>> predNat (Succ (Succ Zero))
-- Succ Zero
-- >>> predNat Zero
-- Zero
predNat :: Nat -> Nat
predNat = undefined

-- Конвертиране на Integer в Nat
--
-- Примери:
-- >>> integerToNat 4
-- Succ (Succ (Succ (Succ Zero)))
integerToNat :: Integer -> Nat
integerToNat = undefined

-- Конвертиране на Nat в Integer
-- Трябва (integerToNat . natToInteger) да е идентитет за стойности от тип Nat
-- Обратното не е вярно!
natToInteger :: Nat -> Integer
natToInteger = undefined

-- Събиране за Nat
-- Не може да използвате natToInteger!
--
-- Примери:
-- >>> plus (integerToNat 1) (integerToNat 2)
-- Succ (Succ (Succ Zero))
plus :: Nat -> Nat -> Nat
plus = undefined

-- Умножение за Nat
-- Не може да използвате natToInteger!
--
-- Примери:
-- >>> natToInteger $ mult (integerToNat 3) (integerToNat 2)
-- 6
mult :: Nat -> Nat -> Nat
mult = undefined

-- При делене на 0 операцията е неуспешна.
-- В противен случай искаме да върнем двойка от коефицент и остатък
--
-- Примери:
-- >>> safeDiv 5 0
-- Nothing
-- >>> safeDiv 13 5
-- Just (2, 3)
safeDiv :: Int -> Int -> Maybe (Int, Int)
safeDiv = undefined

-- Проверява дали списък от списъци е квадратна матрица
isSquareMatrix :: [[a]] -> Bool
isSquareMatrix = undefined

-- Връща главния диагонал на матрица (списък от списъци)
mainDiag :: [[a]] -> [a]
mainDiag = undefined

-- Връща вторичния диагонал на матрица (списък от списъци)
secondaryDiag :: [[a]] -> [a]
secondaryDiag = undefined

-- (a,b,c) е Питагорова тройка ако: a*a + b*b = c*c
-- Да се напише функция която генерира безкраен списък
-- от всички Питагорови тройки.
pythagoreanTriples :: [(Int, Int, Int)]
pythagoreanTriples = undefined

-- Търсим стойност по ключ в асоциативен списък (списък от двойки).
-- Може да не намерим такава.
--
-- Примери:
-- >>> lookup 5 [(10, 'a'), (5,'c')]
-- Just 'c'
-- >>> lookup 13 [(10, 'a'), (5,'c')]
-- Nothing
lookup :: Eq k => k -> [(k, v)] -> Maybe v
lookup = undefined

-- Проверка за съществуване на елемент, изпълняващ даден предикат.
-- Примери:
-- >>> findPred even  (Node 1 (Node 3 Leaf Leaf) (Node 2 Leaf Leaf))
-- Just 2
-- >>> findPred (>20) (Node 1 (Node 3 Leaf Leaf) (Node 2 Leaf Leaf))
-- Nothing
findPred :: (a -> Bool) -> BTree a -> Maybe a
findPred = undefined

g :: Graph Int
g =
  [ GNode 1 [2, 3],
    GNode 2 [4],
    GNode 3 [5],
    GNode 4 [],
    GNode 5 [1, 4]
  ]

-- Връща броя наследници на даден връх
outDeg :: Graph a -> a -> Int
outDeg = undefined

-- Връща броя родители на даден връх
inDeg :: Graph a -> a -> Int
inDeg = undefined

-- Проверява дали има ребро между два върха
edge :: Graph a -> a -> a -> Bool
edge = undefined

-- Връща (Just) някой път между два върха. Nothing - ако няма такъв.
path :: Graph a -> a -> a -> Maybe [a]
path = undefined

-- Връща (Just) най-кратък път между два върха. Nothing - ако няма такъв.
shortestPath :: Graph a -> a -> a -> Maybe [a]
shortestPath = undefined
