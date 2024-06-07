/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  reactStrictMode: true,
  async redirects() {
    return [
      {
        source: "/",
        destination: "/users",
        permanent: true,
      },
    ];
  },
};

module.exports = nextConfig;
