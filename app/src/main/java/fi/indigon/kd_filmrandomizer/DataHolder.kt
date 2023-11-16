package fi.indigon.kd_filmrandomizer


object DataHolder {
    var FilmArray: Array<Film>? = null
        private set
    var DevMode = false
        private set

    var SettingFilterWatched = false
        private set

    fun setFilmArray(filmArray: Array<Film>) {
        FilmArray = filmArray
    }

    fun setDevMode(boolean: Boolean) {
        DevMode = boolean
    }

    fun setFilterWatchedSetting(boolean: Boolean) {
        SettingFilterWatched = boolean
    }

    // region TODO SWITCH EDIT_FILM_ACTIVITY TO USE SINGLETON
    //    var CurrentFilm: Film? = null
    //        private set
    //
    //    fun setCurrentFilm(film: Film) {
    //        CurrentFilm = film
    //    }
    // endregion

    fun clearData() {
        FilmArray = null
        //CurrentFilm = null
    }

}