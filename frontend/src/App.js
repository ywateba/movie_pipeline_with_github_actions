import React, { useState } from 'react';
import MovieList from './components/MovieList';
import MovieDetails from './components/MovieDetails';
import './App.css';

export default function App() {
  const [selectedMovie, setSelectedMovie] = useState(null);
  const movies = [
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
