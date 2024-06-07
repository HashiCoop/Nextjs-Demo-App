"use client";

import { TextField, Button, Box, Grid } from "@mui/material";
import { useState } from "react";

export default function ListUsers() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const handleOnSubmit = () => {
    fetch("/api/user", {
      method: "POST",
      body: JSON.stringify({ name, email }),
    })
      .then((resp) => console.log(resp))
      .catch((err) => console.log(err));
  };

  return (
    <Box justifyContent="flex-end">
      <form onSubmit={handleOnSubmit}>
        <Grid
          container
          direction="column"
          justifyContent="flex-end"
          alignItems="center"
          rowGap={2}
        >
          <TextField
            id="name"
            label="Name"
            onInput={(e) => setName(e.target.value)}
          />
          <TextField
            id="email"
            label="Email"
            onInput={(e) => setEmail(e.target.value)}
          />
          <Button type="submit">Submit</Button>
        </Grid>
      </form>
    </Box>
  );
}
