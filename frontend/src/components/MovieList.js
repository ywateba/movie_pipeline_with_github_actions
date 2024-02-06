import React from 'react';
import MovieDetails from './MovieDetails';

// MovieList component
const MovieList = (movies, onMovieClick) => {
  return (
    <div>
      {movies.map((movie, index) => (
        <MovieDetails key={index} movie={movie} onClick={() => onMovieClick(movie)} />
      ))}
    </div>
  );
};
export default MovieList;
