//
//  Constants.swift
//  MovieMe
//
//  Created by Meitar Basson on 25/09/2020.
//  Copyright © 2020 Meitar Basson. All rights reserved.
//

import Foundation

let API_KEY = ""
let BASE_URL = "https://api.themoviedb.org/3/"
let TRENDING_MOVIE_URL = BASE_URL + "trending/movie/day?api_key=" + API_KEY
let TRENDING_SERIES_URL = BASE_URL + "trending/tv/day?api_key=" + API_KEY
let IMAGE_BASE = "https://image.tmdb.org/t/p/w500"
let SEARCH_URL_SERIES = "https://api.themoviedb.org/3/search/tv?api_key=" + API_KEY + "&language=en-US&query="
let SEARCH_URL_MOVIES = "https://api.themoviedb.org/3/search/movie?api_key=" + API_KEY + "&language=en-US&query="
