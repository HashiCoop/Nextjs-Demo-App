"use client";

import {
  Drawer,
  Divider,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
} from "@mui/material";

import Link from "next/link";
import { usePathname } from "next/navigation";

const drawerWidth = 240;

export default function Sidebar() {
  const path = usePathname();

  return (
    <Drawer
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        "& .MuiDrawer-paper": {
          width: drawerWidth,
          boxSizing: "border-box",
        },
      }}
      variant="permanent"
      anchor="left"
    >
      <Divider />
      <List>
        {[
          { text: "Users", link: "/users" },
          { text: "Add User", link: "/addUser" },
          { text: "System Info", link: "systemInfo" },
        ].map((item, index) => (
          <ListItemButton
            key={item.link}
            component={Link}
            href={item.link}
            selected={item.link === path}
          >
            <ListItemText primary={item.text} />
          </ListItemButton>
        ))}
      </List>
      <Divider />
    </Drawer>
  );
}
