-- This file is part of purebred-email
-- Copyright (C) 2017-2020  Róman Joost and Fraser Tweedale
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

import Test.Tasty

import ContentTransferEncodings as CTE
import EncodedWord
import MIME
import Headers
import Generator
import Parser
import Message

main :: IO ()
main =
  defaultMain $ testGroup "Tests"
    [ CTE.properties
    , EncodedWord.properties
    , Headers.unittests
    , Generator.properties
    , MIME.unittests
    , Parser.tests
    , Message.tests
    ]
