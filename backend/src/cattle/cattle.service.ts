import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cattle } from './cattle.entity';
import { CreateCattleDto } from './dto/create-cattle.dto';
import { UpdateCattleDto } from './dto/update-cattle.dto';

@Injectable()
export class CattleService {
  constructor(
    @InjectRepository(Cattle) private repo: Repository<Cattle>,
  ) {}

  findAll(ownerId?: number, isSold?: boolean): Promise<Cattle[]> {
    const where: any = {};
    if (ownerId !== undefined) where.ownerId = ownerId;
    if (isSold !== undefined) where.isSold = isSold;
    return this.repo.find({ where, order: { createdAt: 'DESC' } });
  }

  async findOne(id: number): Promise<Cattle> {
    const cattle = await this.repo.findOne({ where: { id }, relations: ['sale'] });
    if (!cattle) throw new NotFoundException(`Cattle with id ${id} not found`);
    return cattle;
  }

  async create(dto: CreateCattleDto): Promise<Cattle> {
    const exists = await this.repo.findOneBy({ cattleUniqueId: dto.cattleUniqueId });
    if (exists) throw new ConflictException(`Cattle ID "${dto.cattleUniqueId}" already exists`);
    return this.repo.save(this.repo.create(dto));
  }

  async update(id: number, dto: UpdateCattleDto): Promise<Cattle> {
    const cattle = await this.findOne(id);
    Object.assign(cattle, dto);
    return this.repo.save(cattle);
  }

  async markAsSold(id: number): Promise<void> {
    await this.repo.update(id, { isSold: true });
  }

  async markAsActive(id: number): Promise<void> {
    await this.repo.update(id, { isSold: false });
  }

  async remove(id: number): Promise<void> {
    const cattle = await this.findOne(id);
    await this.repo.remove(cattle);
  }

  findByOwner(ownerId: number): Promise<Cattle[]> {
    return this.repo.find({ where: { ownerId }, relations: ['sale'] });
  }
}
