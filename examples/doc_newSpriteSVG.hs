#!/usr/bin/env stack
-- stack runghc --package reanimate
module Main(main) where

import Reanimate
import Reanimate.Builtin.Documentation

main :: IO ()
main = reanimate $ docEnv $ sceneAnimation $ do
  _ <- newSpriteSVG $ mkBackground "lightblue"
  play drawCircle
