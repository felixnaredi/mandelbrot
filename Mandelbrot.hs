{-# LANGUAGE TupleSections #-}

module Mandelbrot where

type Complex a = (a, a)

mul :: Num a => Complex a -> Complex a -> Complex a
mul (x, a) (y, b) = (x * y - a * b, x * b + y * a)

add :: Num a => Complex a -> Complex a -> Complex a
add (x, a) (y, b) = (x + y, a + b)

fc :: Num a => Complex a -> [Complex a]
fc c = f' (0, 0) where f' z = add (mul z z) c : f' (add (mul z z) c)

range :: Fractional a => Integer -> a -> a -> [a]
range n x y = map (\k -> x + v * fromIntegral k) [0 .. n]
    where v = (y - x) / fromIntegral n

bounded :: (Fractional a, Eq a) => [Complex a] -> Bool
bounded = not . any (\(x, a) -> abs x == 1 / 0 || abs a == 1 / 0) . take 32

mandelbrot
    :: (Ord a, Fractional a)
    => (Integer, Integer)
    -> Complex a
    -> Complex a
    -> IO ()
mandelbrot (w, h) (x, a) (y, b)
    | x > y = mandelbrot (w, h) (y, a) (x, b)
    | a < b = mandelbrot (w, h) (x, b) (y, a)
    | otherwise = mapM_
        (putStrLn . map ((\b -> if b then '*' else ' ') . bounded . fc))
        c
  where
    c     = map (\a -> map (, a) reals) imgs
    reals = range w x y
    imgs  = range h a b

