import Control.Monad (unless)
import Data.Bits (shiftR, (.&.))
import System.IO (isEOF)

main :: IO ()
main = outer where
  outer = do
    e <- isEOF
    unless e $ do
      l <- getLine
      mapM_ putStrLn
        $ appspl ["FONT"] '-' [id, id, id, id, id, id, double, double, id, id, id, double]
        =<< appspl ["SIZE"] ' ' [double]
        =<< doubles ["FONTBOUNDINGBOX"]
        l
      case l of
        'S':'T':'A':'R':'T':'P':'R':'O':'P':'E':'R':'T':'I':'E':'S':' ':_ -> loop "ENDPROPERTIES" props
        'S':'T':'A':'R':'T':'C':'H':'A':'R':' ':_ -> loop "BITMAP" char >> loop "ENDCHAR" bitmap
        _ -> return ()
      outer
  loop e f = do
    l <- getLine
    if l == e
      then putStrLn l
      else do
        mapM_ putStrLn $ f l
        loop e f
  props = doubles ["PIXEL_SIZE", "POINT_SIZE", "AVERAGE_WIDTH", "FONT_ASCENT", "FONT_DESCENT", "CAP_HEIGHT", "X_HEIGHT"]
  char = doubles ["SWIDTH", "DWIDTH", "BBX"]
  doubles l = appspl l ' ' (repeat double)
  appspl l d f s =
    [if p `elem` l
      then p ++ mapspl d f v
      else s]
    where (p, v) = break (' ' ==) s
  mapspl d fs@(f:fs') s@(c:s')
    | c == d = c : mapspl d fs s'
    | otherwise = f p ++ mapspl d fs' r where (p, r) = break (d ==) s
  mapspl _ _ s = s
  double = show . (*) (2 :: Int) . read
  bitmap s = [d,d] where
    d = foldMap (byte . rh) s
  byte b = [word (b `shiftR` 2), word (b .&. 3)]
  word 0 = '0'
  word 1 = '3'
  word 2 = 'C'
  word 3 = 'F'
  rh c
    | c >= '0' && c <= '9' = fromEnum c - fromEnum '0'
    | c >= 'a' && c <= 'f' = 10 + fromEnum c - fromEnum 'a'
    | c >= 'A' && c <= 'F' = 10 + fromEnum c - fromEnum 'A'
