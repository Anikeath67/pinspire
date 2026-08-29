const { onRequest } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

exports.searchPhotos = onRequest(
  {
    region: 'asia-south1',
    cors: true,
    secrets: ['DzjeiCRrtbZ3sXowCKRiRuBEOmZigWLdIpkPfO3ybnLEQSHjrnr6HNBU'],
  },
  async (req, res) => {
    try {
      const query = String(req.query.query || 'anime').trim();
      const page = Math.max(1, Number(req.query.page || 1));
      const perPage = Math.min(
        80,
        Math.max(1, Number(req.query.per_page || 30)),
      );

      const url = new URL('https://api.pexels.com/v1/search');
      url.searchParams.set('query', query);
      url.searchParams.set('page', String(page));
      url.searchParams.set('per_page', String(perPage));

      const response = await fetch(url, {
        headers: {
          Authorization: process.env.PEXELS_API_KEY,
        },
      });

      if (!response.ok) {
        return res
            .status(502)
            .json({ error: 'Image provider unavailable.' });
      }

      const data = await response.json();

      return res.json({
        photos: (data.photos || []).map((photo) => ({
          id: photo.id,
          imageUrl:
              photo.src.large || photo.src.medium || photo.src.original,
          originalUrl: photo.src.original,
          photographer: photo.photographer || 'Pexels creator',
        })),
      });
    } catch (error) {
      logger.error(error);
      return res.status(500).json({
        error: 'Internal server error.',
      });
    }
  },
);
