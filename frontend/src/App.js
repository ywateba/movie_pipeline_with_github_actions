import React, { useState, useEffect } from 'react';
import MovieList from './components/MovieList';
import MovieDetails from './components/MovieDetails';
import './App.css';

export default function App() {
  const [selectedMovie, setSelectedMovie] = useState(null);
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const handleMovieClick = (movie) => {
    setSelectedMovie(movie);
  };

  const REACT_APP_MOVIE_API_URL = process.env.REACT_APP_MOVIE_API_URL;

  const getMovies = async () => {
    try {
      // Start loading
      setLoading(true);
      // Fetch movies from the API
      const response = await fetch(REACT_APP_MOVIE_API_URL + '/movies');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      setMovies(data.movies); // Assuming the API returns an array of movies
    } catch (error) {
      // Catch any errors and set an error state
      setError(error.message);
    } finally {
      // End loading whether there was an error or not
      setLoading(false);
    }
  };

  useEffect(() => {
    getMovies();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="container">
      <h1>Movie List</h1>

      <MovieList movies={movies} onMovieClick={handleMovieClick} />

      {selectedMovie && (
        <>
          <h1>Movie Details</h1>
          <MovieDetails movie={selectedMovie} />
        </>
      )}
    </div>
  );
}
