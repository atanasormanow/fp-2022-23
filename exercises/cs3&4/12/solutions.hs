{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}
-- use different names
{-# OPTIONS_GHC -fwarn-incomplete-uni-patterns #-}
-- use all your pattern matches
{-# OPTIONS_GHC -fwarn-missing-signatures #-}
-- write all toplevel signatures
{-# OPTIONS_GHC -fwarn-name-shadowing #-}
-- cover all cases
{-# OPTIONS_GHC -fwarn-unused-matches #-}

-- no incomplete patterns in lambdas

import Prelude hiding (Maybe (..), lookup)

data BTree a
  = Empty
  | Node a (BTree a) (BTree a)
  deriving (Show)

data Maybe a
  = Nothing
  | Just a
  deriving (Show)

------------
-- ЗАДАЧИ --
------------

-- Връща Just от първият елемент на списък, Nothing ако списъка е празен.
--
-- Примери:
-- >>> safeHead [1,2,3]
-- Just 1
-- >>> safeHead []
-- Nothing
safeHead :: [a] -> Maybe a
safeHead [] = Nothing
safeHead (x : _) = Just x

-- Да се вмъкне елемент в дърво, спрямо наредбата на елементите му.
--
-- Примери:
-- >>> insertOrdered 5 Empty
-- Node 5 Empty Empty
-- >>> insertOrdered 5 (Node 10 Empty Empty)
-- Node 10 (Node 5 Empty Empty) Empty
-- >>> insertOrdered 5 (Node 3 Empty Empty)
-- Node 3 Empty (Node 5 Empty Empty)
insertOrdered :: Ord a => a -> BTree a -> BTree a
insertOrdered x Empty = Node x Empty Empty
insertOrdered x (Node y l r)
  | x > y = Node y l (insertOrdered x r)
  | otherwise = Node y (insertOrdered x l) r

-- Да се построи binary search tree от списък с елементи от тип "a"
-- (използвайте insertOrdered)
--
-- Примери:
-- >>> listToTree [1,10,2,9,3,8]
--
-- Node 8 (Node 3 (Node 2 (Node 1 Empty Empty) Empty) Empty)
--        (Node 9 Empty (Node 10 Empty Empty))
listToTree :: Ord a => [a] -> BTree a
listToTree [] = Empty
listToTree xs = foldr insertOrdered Empty xs

-- По дадено дърво от числа да се намери сбора на елементите му.
sumTree :: Num a => BTree a -> a
sumTree Empty = 0
sumTree (Node x l r) = x + sumTree l + sumTree r

-- Дали за всеки елемент в дърво е изпълнен даден предикат.
-- (Node 5 (Node 2 Empty Empty) (Node 7 Empty Empty))
allTree :: (a -> Bool) -> BTree a -> Bool
allTree _ Empty = True
allTree p (Node x l r) = p x && allTree p l && allTree p r

-- Да се получи списък от обхождането на двоично дърво.
-- Нека обхождането да е ляво-корен-дясно
treeToList :: BTree a -> [a]
treeToList Empty = []
treeToList (Node x l r) = treeToList l ++ x : treeToList r

-- Проверка дали елемент участва в дадено дърво.
--
-- Примери:
-- >>> elemTree 5 (listToTree [1..10])
-- True
-- >>> elemTree 42 (listToTree [1..10])
-- False
elemTree :: Eq a => a -> BTree a -> Bool
elemTree x t = x `elem` treeToList t

-- Проверка за съществуване на елемент, изпълняващ даден предикат.
--
-- Примери:
-- >>> findPred even (listToTree [1..10])
-- Just 2
-- >>> findPred (>20) (listToTree [1..10])
-- Nothing
findPred :: (a -> Bool) -> BTree a -> Maybe a
findPred p t = safeHead [x | x <- treeToList t, p x]

-- За дадено двоично дърво от числа, намира максималната сума от числата
-- по някой път от корена до листо
maxSumPath :: (Num a, Ord a) => BTree a -> a
maxSumPath Empty = 0
maxSumPath (Node x l r) = x + max (maxSumPath l) (maxSumPath r)

-- Реализирайте функция, която за дадено балансирано двоично дърво
-- връща списък от низове, представляващи нивата на дървото
--
-- Пример:
bt :: BTree Int
bt =
  Node
    0
    ( Node
        1
        (Node 3 (Node 7 Empty Empty) Empty)
        (Node 4 (Node 8 Empty Empty) Empty)
    )
    ( Node
        2
        (Node 5 (Node 9 Empty Empty) (Node 10 Empty Empty))
        (Node 6 Empty (Node 11 Empty Empty))
    )

-- >>> printBT bt
-- [“_____0________”,“__1_______2___”,“_3__4__5___6__”,“7__8__9_10__11”]

-- Или ако всеки елемент беше на нов ред:
-- >>> mapM_ putStrLn $ printBT bt
-- _____0________
-- __1_______2___
-- _3__4__5___6__
-- 7__8__9_10__11
--
-- Имайте предвид че броя на "_" зависи от броя на символите,
-- нужни за да се принтират елементите от по-високите нива на дървото
lenBT :: (Show a) => BTree a -> Int
lenBT Empty = 0
lenBT (Node val left right) = length (show val) + lenBT left + lenBT right

printBT :: (Show a) => BTree a -> [String]
printBT Empty = [""]
printBT (Node val Empty Empty) = [show val]
printBT (Node val left right) = (lus ++ show val ++ rus) : treeTail
  where
    lus = replicate (lenBT left) '_'
    rus = replicate (lenBT right) '_'
    vus = replicate (length $ show val) '_'
    treeTail =
      zipWith
        (\x y -> x ++ vus ++ y)
        (printBT left)
        (printBT right)
