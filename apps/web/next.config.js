/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@sharmavideocare/shared", "@sharmavideocare/design-tokens"],
};

module.exports = nextConfig;
