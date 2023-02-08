module Main where

-- Haskell е чист функционален език,
-- но това не означава че не можем да правим странични ефекти.
--
-- Иначе нямаше да можем да пишем полезни програми,
-- такива които взимат вход от външния свят, пишат във файл
-- или пък генерират произволно число.
--
-- Просто в Haskell има ясно разделение между чистите и нечистите функции.
-- Това разделение се постига,
-- като се закодират такива "нечисти" трансформации,
-- като стойности от конкретен тип - IO.
--
-- >>> :k IO
-- IO :: * -> *
--
-- (IO a) е трансформация,
-- която ако бъде извършена ще получим стойност от тип "a"
--
-- >>> :t getLine
-- getLine :: IO String
--
-- >>> :t putStrLn
-- putStrLn :: String -> IO ()

-- TODO: IO (), какво е () и какъв е типа на ()?
--
-- Това ни напомня за main функцията, която сигурно всички са виждали вече.
-- main функцията е входната точка за програмите на Haskell.
-- (като "int main()" в C++)
-- Съответно можем да си компилираме програмата с "ghc io-intro"
main :: IO ()
main = do
  putStrLn "Hello Friend"

-- TODO: Пример с ghc

-- А какво е "do"?
-- do notation е специален синтаксис,
-- който ни позволява да ползваме оператора (<-) за да получим стойността от IO
getInt :: IO Int
getInt = do
  (line :: String) <- (getLine :: IO String)
  return (read line :: Int) -- какъв е типа на return?

-- Освен това можем да пишем let <name> = <expression>
-- за да въведем локална дефиниция.
-- Вижда че можем да пишем програми в стил по-близък до императивният
printMyInt :: IO ()
printMyInt = do
  (n :: Int) <- (getInt :: IO Int)
  let k = n * n
  print k -- какъв е типа на print?

-- С (<-) можем да разопаковаме IO трансформация,
-- а с return можем да опаковаме стойност "a" в трансформация (IO a).
--
-- Забележка! Това не работи с произволни типове, различни от IO!
--
-- Сега като знаем как да разопаковаме и опаковаме такива трансформации,
-- е хубаво да се замислим как да минимизираме броя на такива операции.
--
-- Начина по който работим с стойности от тип (IO a) е:
-- 1. Заопаковаме (IO a), за да получим чиста стойност от тип "а"
-- 2. Работим с чистата стойност (както сме правили досега в курса).
-- 3. Опаковаме обратно в (IO b)
--
-- Типа на тази трансформация изглежда така:
-- IO a -> (a -> b) -> IO b
-- Това е просто map над IO.
--
-- Много често се налага да правим и следното:
-- IO a -> (a -> IO b) -> IO b
--
-- Тоест веднъж влезем ли в света на нечистите стойности, не можем да излезем.
-- Не може да пишем функции от тип: IO a -> a