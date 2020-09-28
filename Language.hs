module Language
  ( For(..)
  , MF
  , MT
  )
where

import Data.Tree

-- | Inductive definition of Formula type
data For =   Verum
            | V Int
            | N For
            | E For For
            | I For For
            | A For For
            | D For For
              deriving(Eq,Read,Show)

-- | generateArb :: Int -> Int -> For

-- | Binding rules for propositional connectives
infix 9 `V`
infix 8 `N`
infixr 7 `A`
infixr 7 `D`
infixr 6 `I`
infix 6 `E`

-- | Maybe formula is a Just formula or Nothing
type MF = Maybe For

-- | Rose trees labelled by lists of maybe formulas
type MT = Tree [MF]
