-- This file is part of purebred-email
-- Copyright (C) 2018  Fraser Tweedale
--
-- purebred-email is free software: you can redistribute it and/or modify
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

{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings #-}

module MIME where

import Data.Char (toUpper)

import Control.Lens
import qualified Data.Text as T

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit ((@?=), testCase)

import Data.MIME

unittests :: TestTree
unittests =
  testGroup "content disposition"
    [ testCase "simple read" $
        preview lFilename
        (Message (Headers [("Content-Disposition", "attachment; filename=foo.pdf")]) (Part ""))
        @?= Just "foo.pdf"
    , testCase "quoted read" $
        preview lFilename
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Just "/tmp/foo.pdf"
    , testCase "modify simple -> simple" $
        (preview lFilename . over lFilename (T.drop 1))
        (Message (Headers [("Content-Disposition", "attachment; filename=foo.pdf")]) (Part ""))
        @?= Just "oo.pdf"
    , testCase "modify quoted -> simple" $
        (preview lFilename . over lFilename stripPath)
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Just "foo.pdf"
    , testCase "modify quoted -> quoted" $
        (preview lFilename . over lFilename (T.map toUpper))
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Just "/TMP/FOO.PDF"
    , testCase "set extended (utf-8; raw)" $
        (view headers . set lFilename "hello世界.txt")
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Headers [("Content-Disposition", "attachment; filename*=utf-8''hello%E4%B8%96%E7%95%8C.txt")]
    , testCase "set extended (utf-8; readback)" $
        (preview lFilename . set lFilename "hello世界.txt")
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Just "hello世界.txt"
    , testCase "set extended (us-ascii; charset omitted; raw)" $
        -- control characters will force it to use percent-encoded extended param,
        -- but all chars are in us-ascii so charset should be omitted
        (view headers . set lFilename "new\nline")
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Headers [("Content-Disposition", "attachment; filename*=''new%0Aline")]
    , testCase "set extended (us-ascii; charset omitted; readback)" $
        -- control characters will force it to use percent-encoded extended param,
        -- but all chars are in us-ascii so charset should be omitted
        (preview lFilename . set lFilename "new\nline")
        (Message (Headers [("Content-Disposition", "attachment; filename=\"/tmp/foo.pdf\"")]) (Part ""))
        @?= Just "new\nline"
    ]
  where
    lFilename = headers . contentDisposition . filename
    stripPath = snd . T.breakOnEnd "/"
