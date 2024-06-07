"use client";

import * as React from "react";
import { useState, useEffect } from "react";
import { unstable_noStore as noStore } from "next/cache";

import {
  ListItemIcon,
  Grid,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

export default function Users() {
  noStore();

  const [users, setUsers] = useState<any>([]);
  const [deleteToggle, setDeleteToggle] = useState(true);

  useEffect(() => {
    fetch("/api/user", { method: "GET" })
      .then((res) => res.json())
      .then((data) => {
        setUsers(data.users);
      });
  }, [deleteToggle]);

  const onClick = (e: React.ChangeEvent<any>) => {
    const email = e.currentTarget.id;

    fetch("/api/user", {
      method: "DELETE",
      body: JSON.stringify({ email }),
    })
      .then((resp) => console.log(resp))
      .catch((err) => console.log(err));

    setDeleteToggle(!deleteToggle);
  };

  try {
    return (
      <>
        <Grid container columns={2}>
          <List>
            {users.map((user: any) => (
              <ListItem key={user.email}>
                <ListItemButton>
                  <Grid item>
                    <ListItemText primary={user.email} />
                  </Grid>
                </ListItemButton>
                <Grid item>
                  <ListItemButton id={user.email} onClick={onClick}>
                    <ListItemIcon>
                      <CloseIcon />
                    </ListItemIcon>
                  </ListItemButton>
                </Grid>
              </ListItem>
            ))}
          </List>
        </Grid>
      </>
    );
  } catch (err) {
    console.log(err);
    return <p>Error fetching user</p>;
  }
}
