module Graphics.D3.Scale
  ( Scale
  , Quantitative
  , LinearScale()
  , PowerScale()
  , LogScale()
  , OrdinalScale()
  , linearScale
  , powerScale
  , sqrtScale
  , logScale
  , ordinalScale
  , domain
  , range
  , copy
  , toFunction
  , invert
  , rangeRound
  , interpolate
  , clamp
  , nice
  , getTicks
  , getTickFormat
  , exponent
  , base
  , rangePoints
  , rangeBands
  , rangeRoundBands
  , rangeBand
  , rangeExtent
  ) where

import Graphics.D3.Base
import Graphics.D3.Interpolate
import Graphics.D3.Unsafe

import Data.Tuple
import Data.Maybe

import Data.Foreign.EasyFFI

ffi = unsafeForeignFunction

-- A base class for all scale types

class Scale s where
  domain :: forall d r. [d] -> s d r -> D3Eff (s d r)
  range :: forall d r. [r] -> s d r -> D3Eff (s d r)
  copy :: forall d r. s d r -> D3Eff (s d r)
  toFunction :: forall d r. s d r -> D3Eff (d -> r)

-- Quantitative (numeric domain) scales

class Quantitative s where
  invert :: s Number Number -> D3Eff (Number -> Number)
  rangeRound :: [Number] -> s Number Number -> D3Eff (s Number Number)
  interpolate :: forall r. Interpolator r -> s Number r -> D3Eff (s Number r)
  clamp :: forall r. Boolean -> s Number r -> D3Eff (s Number r)
  nice :: forall r. Maybe Number -> s Number r -> D3Eff (s Number r)
  getTicks :: forall r. Maybe Number -> s Number r -> D3Eff [Number]
  getTickFormat :: forall r. Number -> Maybe String -> s Number r -> D3Eff (Number -> String)

-- Scale types

foreign import data LinearScale :: * -> * -> *
foreign import data IdentityScale :: * -> * -> *
foreign import data PowerScale :: * -> * -> *
foreign import data LogScale :: * -> * -> *
foreign import data OrdinalScale :: * -> * -> *

-- Scale constructors

foreign import linearScale "var linearScale = d3.scale.linear"
  :: forall r. D3Eff (LinearScale Number r)
foreign import powerScale "var powerScale = d3.scale.pow"
  :: forall r. D3Eff (PowerScale Number r)
foreign import sqrtScale "var sqrtScale = d3.scale.sqrt"
  :: forall r. D3Eff (PowerScale Number r)
foreign import logScale "function logScale() { return d3.scale.log(); }"
  :: forall r. D3Eff (LogScale Number r)
foreign import ordinalScale "var ordinalScale = d3.scale.ordinal"
  :: forall d r. D3Eff (OrdinalScale d r)

-- Power scale methods

exponent :: forall r. Number -> PowerScale Number r -> D3Eff (PowerScale Number r)
exponent = ffi ["k", "scale", ""] "scale.exponent(k)"

-- Log scale methods

base :: forall r. Number -> LogScale Number r -> D3Eff (LogScale Number r)
base = ffi ["base", "scale", ""] "scale.base(base)"

-- Ordinal scale methods

rangePoints :: forall d. Number -> Number -> Number -> OrdinalScale d Number -> D3Eff (OrdinalScale d Number)
rangePoints = ffi
  ["min", "max", "padding", "scale", ""]
  "scale.rangePoints([min, max], padding)"

rangeBands :: forall d. Number -> Number -> Number -> Number -> OrdinalScale d Number -> D3Eff (OrdinalScale d Number)
rangeBands = ffi
  ["min", "max", "padding", "outerPadding", "scale", ""]
  "scale.rangeBands([min, max], padding, outerPadding)"

rangeRoundBands :: forall d. Number -> Number -> Number -> Number -> OrdinalScale d Number -> D3Eff (OrdinalScale d Number)
rangeRoundBands = ffi
  ["min", "max", "padding", "outerPadding", "scale", ""]
  "scale.rangeRoundBands([min, max], padding, outerPadding)"

rangeBand :: forall d r. OrdinalScale d Number -> D3Eff Number
rangeBand = ffi ["scale"] "scale.rangeBand"

rangeExtent :: forall d r. OrdinalScale d Number -> D3Eff (Tuple Number Number)
rangeExtent scale = do
  [min, max] <- ffi ["scale"] "scale.rangeExtent" scale
  return $ Tuple min max

-- Scale class instances

instance scaleLinear :: Scale LinearScale where
  domain = unsafeDomain
  range = unsafeRange
  copy = unsafeCopy
  toFunction = unsafeToFunction

instance quantitativeLinear :: Quantitative LinearScale where
  invert = unsafeInvert
  rangeRound = unsafeRangeRound
  interpolate = unsafeInterpolate
  clamp = unsafeClamp
  nice = unsafeNice
  getTicks = unsafeTicks
  getTickFormat = unsafeTickFormat

instance scalePower :: Scale PowerScale where
  domain = unsafeDomain
  range = unsafeRange
  copy = unsafeCopy
  toFunction = unsafeToFunction

instance quantitativePower :: Quantitative PowerScale where
  invert = unsafeInvert
  rangeRound = unsafeRangeRound
  interpolate = unsafeInterpolate
  clamp = unsafeClamp
  nice = unsafeNice
  getTicks = unsafeTicks
  getTickFormat = unsafeTickFormat

instance scaleLog :: Scale LogScale where
  domain = unsafeDomain
  range = unsafeRange
  copy = unsafeCopy
  toFunction = unsafeToFunction

instance quantitativeLog :: Quantitative LogScale where
  invert = unsafeInvert
  rangeRound = unsafeRangeRound
  interpolate = unsafeInterpolate
  clamp = unsafeClamp
  nice = unsafeNice
  getTicks = unsafeTicks
  getTickFormat = unsafeTickFormat

instance scaleOrdinal :: Scale OrdinalScale where
  domain = unsafeDomain
  range = unsafeRange
  copy = unsafeCopy
  toFunction = unsafeToFunction

unsafeInvert = ffi ["scale", ""] "scale.copy().invert"
unsafeRangeRound = ffi ["values", "scale", ""] "scale.rangeRound(values)"
unsafeInterpolate = ffi ["factory", "scale", ""] "scale.interpolate(factory)"
unsafeClamp = ffi ["bool", "scale", ""] "scale.clamp(bool)"
unsafeNice count = case count of
  Nothing -> ffi ["scale", ""] "scale.nice()"
  Just c -> ffi ["count", "scale", ""] "scale.nice(count)" c
unsafeTicks count = case count of
  Nothing -> ffi ["scale", ""] "scale.ticks()"
  Just c -> ffi ["count", "scale", ""] "scale.ticks(count)" c
unsafeTickFormat count format = case format of
  Nothing -> ffi ["count", "scale", ""] "scale.tickFormat(count)" count
  Just f -> ffi ["count", "format", "scale", ""] "scale.tickFormat(count, format)" count f

