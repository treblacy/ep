{-# language BlockArguments #-} -- :D

import Control.Monad (when)
import Data.List (delete, intercalate)
import Data.Maybe (fromMaybe)
import System.Environment
import System.Exit
import System.IO (hPutStrLn, stderr)

data Cmd = Print | Read Backup | Delete String | Prepend String | Append String
data Backup = BYes | BNo

helpmsg =
    "ep prints or edits elements of PATH\n\
    \ep --help | -h | print | read [-b] | delete DIR | prepend DIR | append DIR\n\
    \read's -b dumps backup \"PATH=...\" to stderr so you have a backup\n\
    \Examples:\n\
    \ep print\n\
    \eval \"$(ep print | sed -e s/6/7/ | ep read)\"\n\
    \eval \"$(ep delete /usr/local/sbin)\"\n\
    \eval \"$(ep append /usr/local/jdk/bin)\"\n"

rejectmsg = "ep: invalid arg. ep --help for args."

main :: IO ()
main = do
    args <- getArgs
    cmd <- case args of
             "print" : _ -> return Print
             "read" : "-b" : _ -> return (Read BYes)
             "read" : [] -> return (Read BNo)
             "delete" : s : _ -> return (Delete s)
             "prepend" : s : _ -> return (Prepend s)
             "append" : s : _ -> return (Append s)
             "--help" : _ -> putStr helpmsg >> exitSuccess
             "-h" : _ -> putStr helpmsg >> exitSuccess
             _ -> hPutStrLn stderr rejectmsg >> exitFailure
    dirs <- fmap (chop . fromMaybe "") (lookupEnv "PATH")
    case cmd of
      Print -> putStr (unlines dirs)
      Read old -> do
          case old of
            BYes -> hPutStrLn stderr (compose dirs)
            BNo  -> return ()
          s <- getContents
          let paths = lines s
          mapM_ sanityCheck paths
          putStrLn (compose paths)
      Delete s -> putStrLn (compose (delete s dirs))
      Prepend s -> sanityCheck s >> putStrLn (compose (s : dirs))
      Append s -> sanityCheck s >> putStrLn (compose (dirs ++ [s]))

chop path = case break (':' ==) path of
  (p1, ':' : more) -> p1 : chop more
  ("", _) -> []
  (p1, _) -> [p1]

-- Sanity check of an input pathname: Free of colons.
-- We go ahead and abort the whole program when failure.
sanityCheck path = when (':' `elem` path) do
    hPutStrLn stderr ("Colon disallowed in " ++ path)
    exitFailure

compose dirs = "PATH='" ++ intercalate ":" dirs ++ "'"
