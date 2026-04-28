import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

// In-memory user store for now — replace with a User entity + TypeORM repo
const users: { id: number; email: string; passwordHash: string }[] = [];
let nextId = 1;

@Injectable()
export class AuthService {
  constructor(private jwt: JwtService) {}

  async register(dto: RegisterDto) {
    const existing = users.find((u) => u.email === dto.email);
    if (existing) throw new ConflictException('Email already registered');

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = { id: nextId++, email: dto.email, passwordHash };
    users.push(user);
    return { id: user.id, email: user.email };
  }

  async login(dto: LoginDto) {
    const user = users.find((u) => u.email === dto.email);
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const valid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    const accessToken = this.jwt.sign({ sub: user.id, email: user.email });
    return { accessToken, expiresIn: 86400 };
  }
}
