#!/usr/bin/env stack
-- stack runghc --package reanimate
{-# LANGUAGE OverloadedStrings #-}
module Main
  ( main
  )
where

import           Reanimate
import           Reanimate.Builtin.Documentation
import           Linear.V2
import           Linear.Vector
import           Linear.Metric
import           Graphics.SvgTree                  hiding ( Text
                                                          , Point
                                                          , height
                                                          )
import           Data.Text                                ( Text )
import qualified Data.Text                     as T
import           Text.Printf
import           Geom2D.CubicBezier                       ( QuadBezier(..)
                                                          , evalBezier
                                                          , Point(..)
                                                          )

main :: IO ()
main = reanimate $ sceneAnimation $ do
  newSpriteSVG_ $ mkBackgroundPixel rtfdBackgroundColor
  newSpriteSVG_ static
  dotPath  <- newVar (QuadBezier (Point 0 0) (Point 0 0) (Point 0 0))
  dotParam <- newVar 0
  newSprite_ $ redDot <$> (evalBezier <$> unVar dotPath <*> unVar dotParam)
  let moveDot a b = do
        pos <- evalBezier <$> readVar dotPath <*> pure 1
        writeVar dotPath $ QuadBezier pos a b
        writeVar dotParam 0
        tweenVar dotParam 5 $ \v -> fromToS v 1 . curveS 2
        wait 1
  wait 1
  moveDot (Point 0 1)    (Point 4 2)
  moveDot (Point (-1) 0) (Point (-4) 3)
  moveDot (Point (0) 0)  (Point (-4) (-3))
  moveDot (Point (0) 0)  (Point (5) (-2))
  moveDot (Point (6) 2)  (Point 2 1)
  moveDot (Point (0) 0)  (Point 0 0)

redDot :: Point Double -> SVG
redDot (Point x y) = translate x y $ mkGroup
  [ translate 0 (-0.5) $ scale 0.5 $ outlinedText $ T.pack $ printf "%.1f,%.1f" x y
  , withFillColor "red" $ mkCircle 0.1
  ]

static :: SVG
static = mkGroup
  [ grid
  , withStrokeColor "grey" $ mkLine (-screenWidth, 0) (screenWidth, 0)
  , withStrokeColor "grey" $ mkLine (0, -screenHeight) (0, screenHeight)
  , curlyBracket (V2 (-screenWidth / 2 + defaultStrokeWidth) (screenHeight / 2))
                 (V2 (screenWidth / 2 - defaultStrokeWidth) (screenHeight / 2))
                 1
  , translate 0 3 $ outlinedText "16 units"
  , curlyBracket (V2 (-screenWidth / 2) (-screenHeight / 2 + defaultStrokeWidth))
                 (V2 (-screenWidth / 2) (screenHeight / 2 - defaultStrokeWidth))
                 1
  , translate (-6.5) 0 $ rotate 90 $ outlinedText "9 units"
  ]

outlinedText :: Text -> SVG
outlinedText txt = mkGroup
  [ center
  $ withStrokeColorPixel rtfdBackgroundColor
  $ withStrokeWidth (defaultStrokeWidth * 8)
  $ withFillOpacity 0
  $ latex txt
  , center $ latex txt
  ]

curlyBracket :: RPoint -> RPoint -> Double -> SVG
curlyBracket from to height =
  withStrokeColor "black"
    $ withFillOpacity 0
    $ withStrokeWidth (defaultStrokeWidth * 2)
    $ mkPath
        [ MoveTo OriginAbsolute [from]
        , CurveTo OriginAbsolute [(from + outwards, halfway, halfway + outwards)]
        , CurveTo OriginAbsolute [(halfway, to + outwards, to)]
        ]
 where
  outwards = case normalize (from - to) ^* height of
    V2 x y -> V2 (-y) x
  halfway = lerp 0.5 from to

grid :: SVG
grid = withStrokeColor "grey" $ withStrokeWidth (defaultStrokeWidth * 0.5) $ mkGroup
  [ mkGroup
    [ translate
          0
          (i / (screenHeight) * screenHeight - screenHeight / 2 - screenHeight / 18)
        $ mkLine (-screenWidth, 0) (screenWidth, 0)
    | i <- [0 .. screenHeight]
    ]
  , mkGroup
    [ translate (i / (screenWidth) * screenWidth - screenWidth / 2) 0
        $ mkLine (0, -screenHeight) (0, screenHeight)
    | i <- [0 .. screenWidth]
    ]
  ]

