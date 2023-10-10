from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.authtoken.models import Token

from .models import CustomUser
from .serializers import RegistrationSerializer

User = get_user_model()

class RegistrationView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegistrationSerializer

        # Optionally, generate and return an authentication token upon registration
    def create(self, request, *args, **kwargs):
        # Call the parent class's create method to perform user registration
        response = super().create(request, *args, **kwargs)

        # Check if the registration was successful and the user object is available
        if response.status_code == status.HTTP_201_CREATED:
            user = self.queryset.get(username=request.data['username'])

            # Create token for the user
            token = Token.objects.get_or_create(user=user)[0]

            # Return Data
            return Response(
                {
                    'token': token.key,
                    'user_id': user.id,
                    'username': user.username
                },
                status=status.HTTP_201_CREATED  
            )
        return response

class UserLoginView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request, format=None):
        email = request.data.get('email')
        password = request.data.get('password')

        user = User.objects.filter(email=email).first()

        if user and user.check_password(password):
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key, 'user_id': user.id, 'username':user.username}, status=status.HTTP_200_OK)

        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

