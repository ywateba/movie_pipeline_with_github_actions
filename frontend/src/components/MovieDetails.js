import React from 'react';

// MovieDetails component
const MovieDetails = ({ movie }) => {
  return (
    <div>
      <h2>{movie.title}</h2>
      <p>
        <strong>Director:</strong> {movie.director}
      </p>
      <p>
        <strong>Release Year:</strong> {movie.releaseYear}
      </p>
      <p>
        <strong>Summary:</strong> {movie.summary}
      </p>
    </div>
  );
};

export default MovieDetails;
