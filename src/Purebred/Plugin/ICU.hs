-- This file is part of purebred-icu
-- Copyright (C) 2019 Fraser Tweedale
--
-- purebred-icu is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

{- |

Add support for many more charsets to the purebred MUA.  It uses the
/text-icu/ library (and /libicu/ under the hood) to convert text.

Usage:

@
import Purebred
import qualified Purebred.Plugin.ICU

main = purebredWithPlugins [Purebred.Plugin.ICU.plugin, ...]
@

-}
module Purebred.Plugin.ICU
  (
    plugin
  , enable
  , icuCharsets
  ) where

import Control.Applicative ((<|>), liftA2)
import Control.Exception (catch)
import System.IO.Unsafe (unsafePerformIO)

import Data.CaseInsensitive (original)
import Data.MIME (CharsetLookup)
import Data.Text as T
import Data.Text.Encoding as T
import Data.Text.Encoding.Error as T
import Data.Text.ICU.Convert (open, toUnicode)
import Data.Text.ICU.Error (ICUError)

import Paths_purebred_icu (version)
import Purebred
import Purebred.Plugin

-- | Plugin to be used with purebred plugin framework
plugin :: Plugin (ConfigHook Pure)
plugin = Plugin "Purebred.Plugin.ICU" version (ConfigHook (pure . enable))

-- | Install the ICU charsets, preserving and preferring the
-- existing lookup function.
--
enable :: UserConfiguration -> UserConfiguration
enable = over confCharsets (flip (liftA2 (<|>)) icuCharsets)

-- | Just the ICU charset lookup function, in case you want to use
-- it by itself, or combine it with other lookups differently from
-- how 'enable' combines them.
--
icuCharsets :: CharsetLookup
icuCharsets k =
  let
    k' = T.unpack . T.decodeUtf8With T.lenientDecode . original $ k
    handler = const (pure Nothing) :: ICUError -> IO (Maybe a)
    conv = unsafePerformIO $ (Just <$> open k' Nothing) `catch` handler
  in
    toUnicode <$> conv
