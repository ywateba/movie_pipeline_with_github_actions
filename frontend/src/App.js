import React, { useState } from 'react';
import MovieList from './components/MovieList';
import MovieDetails from './components/MovieDetails';
import './App.css';

export default function App() {
  const [selectedMovie, setSelectedMovie] = useState(null);
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const default_movies = [
    {
      title: 'Inception',
      director: 'Christopher Nolan',
      releaseYear: '2010',
      summary:
        'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.',
    },
    {
      title: 'Interstellar',
      director: 'Christopher Nolan',
      releaseYear: '2014',
      summary: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
    },
  ];

  const handleMovieClick = (movie) => {
    setSelectedMovie(movie);
  };



  const getMovies = async () => {
    try {
      // Start loading
      setLoading(true);
      // Fetch movies from the API
      const response = await fetch('http://localhost:5000');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      setMovies(data); // Assuming the API returns an array of movies
    } catch (error) {
      // Catch any errors and set an error state
      setError(error.message);
      setMovies(default_movies)
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
