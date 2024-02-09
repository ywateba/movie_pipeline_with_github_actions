import React from 'react';
import MovieDetails from './MovieDetails';

// MovieList component
const MovieList = ({ movies, onMovieClick }) => {
  return (
    <div>
      {movies.map((movie, index) => (
        <div key={index} onClick={() => onMovieClick(movie)}>
          <MovieDetails movie={movie} />
        </div>
      ))}
    </div>
  );
};
export default MovieList;
